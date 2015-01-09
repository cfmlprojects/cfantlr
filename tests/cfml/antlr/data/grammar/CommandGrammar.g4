grammar CommandGrammar;

@parser::header { package command.grammar;}
@lexer::header { package command.grammar;}
@lexer::members {

  private java.util.Map<String,java.util.Map> namespaces;
  private String namespace;

  public CommandGrammarLexer(CharStream input, java.util.Map<String,java.util.Map> namespaces) {
    this(input);
    this.namespaces = namespaces;
  }

  boolean tryNamespace() {
    // See if a namespace is ahead in the CharStream.
    java.util.Iterator<String> namesIt = namespaces.keySet().iterator();
	String namespace = null;
    while(namesIt.hasNext()) {
		Boolean matched = true;
    	namespace = namesIt.next();
    	for(int i = 0; i < namespace.length(); i++) {
    		if(_input.LA(i + 1) != namespace.charAt(i)) {
    			// Nope, we didn't find the namespace.
    			matched = false;
    		}
    	}
    	if(matched && namespace.length() > 0) {
    		this.namespace = namespace;
		    // Since we found the text, increase the CharStream's index.
		    _input.seek(_input.index() + namespace.length() - 1);
		    return true;
    	}
    }
    return false;
  }
      
  boolean tryCommand() {
    // See if a namespace is ahead in the CharStream.
    java.util.Map<String,java.util.Map> currentNamespace = namespaces.get(this.namespace);
    if(currentNamespace == null) 
    	return false;
    java.util.Iterator<String> commandIt = currentNamespace.keySet().iterator();
	String command = null;
    while(commandIt.hasNext()) {
		Boolean matched = true;
    	command = commandIt.next();
    	for(int i = 0; i < command.length(); i++) {
    		if(_input.LA(i + 1) != command.charAt(i)) {
    			matched = false;
    		}
    	}
    	if(matched) {
		    _input.seek(_input.index() + command.length() - 1);
		    return true;
    	}
    }
    return false;
  }
}

// Parser Rules
 
commandLine : (namespace? command) ;
 
namespace : NAMESPACENAME ;

command :  commandName arguments?;

commandName : COMMANDNAME;

arguments:
	argument*
;

argument:
     (DASH? argumentName EQUALS value)
|
    (value)
;

argumentName: TEXT DASH? TEXT?;

value :  STRING | TEXT;

// Lexer Rules

//WSPACE : (' ' |'\t');
WSPACE : (' ' |'\t') -> skip;
//WSPACE : (' ' |'\t') -> channel(HIDDEN);

EQUALS : '=';

DASH : '-';

NAMESPACENAME
	    : {tryNamespace()}? . ;

COMMANDNAME
	    : {tryCommand()}? . ;

STRING :
    DQUOTE (~('"' | '\\' | '\r' | '\n') | '\\' (DQUOTE | '\\'))* DQUOTE
       |
    SQUOTE (~('\'' | '\\' | '\r' | '\n') | '\\' (SQUOTE | '\\'))* SQUOTE
       ;

NULL: '\u0000' ;

SQUOTE : '\u0027' ;

DQUOTE: '\u0022' ;

TEXT : [a-zA-Z0-9_\\/,\.:;\[\]\(\)\#\%\&\+\$\@\^\!\{\}]+ ;
