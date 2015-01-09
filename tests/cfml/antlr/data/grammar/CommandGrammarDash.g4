grammar CommandGrammar;

@parser::header { package command.grammar;}
@lexer::header { package command.grammar;}
@lexer::members {

  private java.util.Set<String> namespaces;

  public CommandGrammarLexer(CharStream input, java.util.Set<String> namespaces) {
    this(input);
    this.namespaces = namespaces;
  }

  boolean tryToken() {
    // See if a namespace is ahead in the CharStream.
    java.util.Iterator<String> namesIt = namespaces.iterator();
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
    	if(matched) {
		    // Since we found the text, increase the CharStream's index.
		    _input.seek(_input.index() + namespace.length() - 1);
		    return true;    		
    	}
    }
    return false;
    
  }

}

// Parser Rules
 
commandLine : namespace? command ;
 
namespace : NAMESPACE;

command : commandName argument*;

commandName : TEXT;

argumentName : TEXT; 

argument: 
    HYPHEN HYPHEN? argumentName (EQUALS (value)  (COMMA (value) )* )? 
;

value : STRING | TEXT ;

// Lexer Rules
NAMESPACE
	    : {tryToken()}? . ;

TEXT : [a-zA-Z0-9][a-zA-Z0-9\-_]+ ;

STRING :
    DQUOTE (~('"' | '\\' | '\r' | '\n') | '\\' (DQUOTE | '\\'))* DQUOTE
       |
    SQUOTE (~('\'' | '\\' | '\r' | '\n') | '\\' (SQUOTE | '\\'))* SQUOTE
       ;

WSPACE : (' ' |'\t') {skip();};

EQUALS : '\u003d' ;

HYPHEN : '-' ;

COMMA: '\u002c' ;

NULL: '\u0000' ;

SQUOTE : '\u0027' ;

DQUOTE: '\u0022' ;