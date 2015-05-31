/**
 * Parser Example
 * @author Denny Valliant
 **/
component output="false" persistent="false" {

	/**
	 * constructor
	 **/
	function init(reloadGrammar=false) {
		variables.errors = [];
  		thisdir = getDirectoryFromPath(getMetaData(this).path);
		if(reloadGrammar) {
			var grammarFile = expandPath("/tests") & "/cfml/antlr/data/grammar/CommandGrammar.g4";
			var name = listFirst(getFileFromPath(grammarFile),".");
			!directoryExists(thisdir & "/gramlib") ? directoryCreate(thisdir & "/gramlib") : "";
			new Tool().generateJar(grammarFile, thisdir & "/gramlib/#name#.jar");
		}
	  	cl = new lib.LibraryLoader(thisdir & "/lib/jars/," & thisdir & "/gramlib/", reloadGrammar);
		java = {
		 	System : cl.create( 'java.lang.System' )
			,CommonTokenStream : cl.create("org.antlr.v4.runtime.CommonTokenStream")
			,ANTLRInputStream : cl.create("org.antlr.v4.runtime.ANTLRInputStream")
			,RailoListener : cl.create("cfantlr.RailoListener")
			,ExceptionErrorStrategy : cl.create("cfantlr.ExceptionErrorStrategy")
			,CommandGrammarLexer : cl.create("command.grammar.CommandGrammarLexer")
			,CommandGrammarParser : cl.create("command.grammar.CommandGrammarParser")
		};
		cr = java.System.getProperty("line.separator");
		return this;
	}

	function setCommands(commands) {
		variables.commands = commands;
	}

	function getCommands() {
		return variables.commands;
	}

	function getErrors() {
		return variables.errors;
	}

	function syntaxError(recognizer, offendingSymbol, line, charPositionInLine, msg, sourcename, recognitionException)
	{
//		request.debug(arguments.recognitionException.getCause());
//		request.debug(offendingSymbol);
		var symbol = {};
		var treeInfo = {};
		if(!isNull(offendingSymbol)) {
			var tokenname = "";
			var tokenmap = recognizer.getTokenTypeMap();
			for (var entry in tokenmap) {
	            if (tokenmap[entry] ==  offendingSymbol.getType()) {
	                tokenname = entry;
	            }
	        }
			symbol =  {
				string:offendingSymbol.toString(),
				startIndex:offendingSymbol.getStartIndex(),
				stopIndex:offendingSymbol.getStopIndex(),
				stringvalue:offendingSymbol.toString(),
				text:offendingSymbol.getText(),
				type:tokenname & " (#offendingSymbol.getType()#)"
			};
			treeInfo =  {
				info:recognizer.getContext().toInfoString(recognizer),
				tree:recognizer.getContext().toStringTree(recognizer),
				string:recognizer.getContext().toString(recognizer),
				stack:recognizer.getRuleInvocationStack().toString()
			};
		}
		var err = {
			line:line,
			offendingSymbol:symbol,
			charPositionInLine:charPositionInLine,
			parse : treeInfo,
			sourcename:sourcename,
			message:msg
		}

		arrayAppend(errors,err);
	}

	/**
	 * parse the line
	 **/
	function parse(commandLine) {
		var input = java.ANTLRInputStream.init(commandLine);
		var lexer = java.CommandGrammarLexer.init(input, variables.commands);
		var railoListener = java.RailoListener.init();
//        var railoListener =  createDynamicProxy(this, ["org.antlr.v4.runtime.ANTLRErrorListener"]);
		railoListener.setListener(this);
		lexer.removeErrorListeners();
		lexer.addErrorListener(railoListener);
	    var parser = java.CommandGrammarParser.init(java.CommonTokenStream.init(lexer));
		parser.removeErrorListeners();
		parser.addErrorListener(railoListener);
//		parser.setErrorHandler(java.ExceptionErrorStrategy.init());
		try {
		    var tree = parser.commandLine();
		} catch (any e) {
			throw(type="cfml.antlr.parser.error", message=e.message);
		}
//		request.debug(commandLine);
//		request.debug(getErrors());
//	    request.debug(tree.toString());
	    //request.debug(tree);
/*
	    request.debug(listener.getErrors());
	    request.debug(tree.getPayload());
	    request.debug(tree);
	    request.debug(tree.command().toString());
	    request.debug(tree.command().argument().size());
	    request.debug(tree.toInfoString(parser));
	    request.debug(tree.toStringTree(parser));
*/
	//    request.debug(tree.getRuleContext());
	    return {
	    	"stringtree":tree.toStringTree(parser),
	    	"infostring":tree.toInfoString(parser),
	    	"tree":tree,
	    	"messages":getErrors()};

	}

}