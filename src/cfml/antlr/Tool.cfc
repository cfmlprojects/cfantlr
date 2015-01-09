component {

  	cl = new lib.LibraryLoader();
  	thisdir = getDirectoryFromPath(getMetaData(this).path);
	java = {
		  System        : cl.create( 'java.lang.System' )
		, antlr	: cl.create( 'org.antlr.v4.Tool')
		, ByteArrayOutputStream	: cl.create( 'java.io.ByteArrayOutputStream')
		, PrintStream	: cl.create( 'java.io.PrintStream')
	};

	function generateJava( required String grammarFile, String srcDirectory ) {
		!directoryExists(srcDirectory) ? directoryCreate(srcDirectory) : "" ;
		var tool = java.antlr.init( [grammarFile, "-o", srcDirectory] );
		var baos = java.ByteArrayOutputStream.init();
		var ps = java.PrintStream.init(baos);
	    // IMPORTANT: Save the old System.out!
	    var old = java.System.out;
	    var oldErr = java.System.err;
	    java.System.setOut(ps);
	    java.System.setErr(ps);
	    try {
		    tool.processGrammarsOnCommandLine();
	    } catch (any e) {
	    	e.printStackTrace();
	    } finally {
		    java.System.out.flush();
		    java.System.err.flush();
		    java.System.setOut(old);
		    java.System.setErr(oldErr);
	    }
	    var result = baos.toString();
	    if (find("error",result)) {
	    	throw(type="cfml.antlr.javagen.error", message=result);
	    }
	    return result;
	}

	function generateJar( required String grammarFile, required String jarFile, String srcDirectory, String binDirectory="", String compilerArgs="" ) {
		srcDirectory = isNull(srcDirectory)
			? getTempDirectory() & "/" & hash(grammarFile)
			: srcDirectory ;
		generateJava(grammarFile, srcDirectory);
		fileExists(jarFile) ? fileDelete(jarFile) : "";
		!directoryExists(srcDirectory & "/cfantlr") ? directoryCreate(srcDirectory & "/cfantlr") : "";
		fileCopy(thisdir & "resource/RailoListener.java",srcDirectory & "/cfantlr/RailoListener.java");
		fileCopy(thisdir & "resource/ExceptionErrorStrategy.java",srcDirectory & "/cfantlr/ExceptionErrorStrategy.java");
		var jar = new cfml.javatools.Compiler().compileAndJar(srcDirectory,jarFile,binDirectory,cl.getClassLoaderJars(),"-1.7 -nowarn");
		//directoryDelete(binDirectory,true);
		return jar;
	}

	function parse(required String commandLine) {
		var coms = {
			"box":{"createme":{"blah":"blah"},"woohoo":{"functions":"here"}}
			,"":{"dir":{"blah":"blah"},"woohoo":{"functions":"here"}}
			,"coldbox":{"create controller":{"name":"blah"},"woohoo":{"functions":"here"}}
			,"cfdistro":{"init":{"name":"blah"},"woohoo":{"functions":"here"}}
		};
		var parser = new ParserExample(false);
		parser.setCommands(coms);
		request.debug("****************************************************************");
		request.debug(commandLine);
		var result = parser.parse(commandLine);
		request.debug(result.messages);
//	    request.debug(tree.toString());
	    //request.debug(tree);
/*
	    request.debug(listener.getErrors());
	    request.debug(tree.getPayload());
	    request.debug(tree);
*/
	//    request.debug(tree.getRuleContext());
	    request.debug(result.tree.command().toString());
//	    request.debug(result.tree.command().arguments().size());
	    request.debug(result.infoString);
	    request.debug(result.stringTree);
	    return result.tree;
	}

	function testGrammar(required String grammarFile, refresh=false) {
		var name = listFirst(getFileFromPath(grammarFile),".");
		!directoryExists(thisdir & "/gramlib") ? directoryCreate(thisdir & "/gramlib") : "";
		generateJar(grammarFile,thisdir & "/gramlib/#name#.jar");
  		gl = new lib.LibraryLoader(thisdir & "/lib/jars/," & thisdir & "/gramlib/", true);
  		parse("dir .");
  		parse("dir /");
  		parse("dir -fart=wee");
  		parse("dir -fart");
  		parse("dir a");
  		parse("cfdistro init author=dan");
  		parse("dir fart/");
  		parse("cfdistro");
  		parse("cfdistro init");
  		parse("cfdistro init author='pete'");
  		parse("cfdistro init author='pete and stuff' -author-name='fart'");
  		parse("blorg");
  		parse("blorg ");
  		parse("coldbox create controller users");
  		parse('coldbox create controller "users"');
  		parse("coldbox create controller name=users actions=index,save");
  		parse('forgebox install "slug" ');
  		parse("blorg ds=");
  		java.System.gc();

	    return true;

	}

}