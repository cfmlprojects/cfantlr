component extends="mxunit.framework.TestCase" {

	function setUp() {
		tool = new cfml.antlr.Tool();
		var thisDir = getDirectoryFromPath(getMetadata(this).path);
		grammar_com = thisDir & "/data/grammar/CommandGrammar.g4";
		bin = thisDir & "/work/grammar";
		if (directoryExists(bin))
			directoryDelete(bin,true);
		directoryCreate(bin);
	}

	function testGenerateJava() {
		var result = tool.generateJava(grammar_com,bin);
		debug(result);
		assertTrue(fileExists(bin & "/CommandGrammarLexer.java"));
	}

	function testCompileJarGrammar() {
		var jar = bin & "/grammar.jar";
		tool.generateJar(grammar_com, jar, bin);
		zip action="list" file=jar name="content";
		debug(content);
		assertEquals("META-INF/MANIFEST.MF",content.name[1]);
		assertEquals("META-INF",content.directory[1]);
		assertEquals("cfantlr/RailoListener.class",content.name[2]);
		assertEquals("cfantlr",content.directory[2]);
	}

	function testJarGrammarRun() {
		var result = tool.testGrammar(grammar_com);
		request.debug(result);
	}

}