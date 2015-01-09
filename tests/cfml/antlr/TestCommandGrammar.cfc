component extends="mxunit.framework.TestCase" {
//component extends="testbox.system.testing.TestBox" {

	candidates = createObject("java","java.util.TreeSet");

	public void function setUp()  {
		parser = new cfml.antlr.ParserExample(reloadGrammar=true);
		commands = {
			"":{
				"dir":{"directory":"string", "recurse":false},
				"directory":{"directory":"string", "recurse":false},
				"version":{},
				"help":{"command":{"string":"name"}}
				}
			,"coldbox":{
				"create controller":{"name":"blah"},"woohoo":{"functions":"here"}
				}
			,"cfdistro":{
				"init":{"name":"blah"},"dependency":{"functions":"here"}
				}
		};
		commands = deserializeJSON(fileRead(expandPath("/tests/cfml/antlr/data/grammar/commands.json")));
		parser.setCommands(commands);

	}

	public void function testParseCommands()  {
		var parse = parser.parse("dir");
		var commandLine = parse.tree;
		var messages = parse.messages;
		assertTrue(isNull(commandLine.namespace()));
		assertEquals("dir", commandLine.command().getText());
		assertEquals(0, commandLine.command().arguments().argument().size());
		assertEquals(0, messages.size());

		parse = parser.parse("dir /");
		commandLine = parse.tree;
		messages = parse.messages;
		debug(parse.stringtree);
		debug(parse.infostring);
		debug(messages);
		assertEquals(0, messages.size());
		assertTrue(isNull(commandLine.namespace()));
		assertEquals("dir", commandLine.command().commandName().getText());
		assertEquals(1, arrayLen(commandLine.command().arguments().argument()));
		assertEquals("/", commandLine.command().arguments().argument()[1].value().getText());

		parse = parser.parse("dir .");
		commandLine = parse.tree;
		messages = parse.messages;
		debug(parse.stringtree);
		debug(parse.infostring);
		debug(messages);
		assertEquals(0, messages.size());
		assertTrue(isNull(commandLine.namespace()));
		assertEquals("dir", commandLine.command().commandName().getText());
		assertEquals(1, arrayLen(commandLine.command().arguments().argument()));
		assertEquals(".", commandLine.command().arguments().argument()[1].value().getText());

		parse = parser.parse("dir /woot");
		commandLine = parse.tree;
		messages = parse.messages;
		debug(parse.stringtree);
		debug(parse.infostring);
		debug(messages);
		assertEquals(0, messages.size());
		assertTrue(isNull(commandLine.namespace()));
		assertEquals("dir", commandLine.command().commandName().getText());
		assertEquals(1, arrayLen(commandLine.command().arguments().argument()));
		assertEquals("/woot", commandLine.command().arguments().argument()[1].value().getText());

		parse = parser.parse("dir directory=/");
		commandLine = parse.tree;
		messages = parse.messages;
		debug(parse.stringtree);
		debug(parse.infostring);
		debug(messages);
		assertEquals(0, messages.size());
		assertTrue(isNull(commandLine.namespace()));
		assertEquals("dir", commandLine.command().commandName().getText());
		assertEquals(1, arrayLen(commandLine.command().arguments().argument()));
		assertEquals("directory", commandLine.command().arguments().argument()[1].argumentName().getText());
		assertEquals("/", commandLine.command().arguments().argument()[1].value().getText());

		parse = parser.parse("dir directory=blah ");
		commandLine = parse.tree;
		messages = parse.messages;
		debug(parse.stringtree);
		debug(parse.infostring);
		debug(messages);
		assertEquals(0, messages.size());
		assertTrue(isNull(commandLine.namespace()));
		assertEquals("dir", commandLine.command().commandName().getText());
		assertEquals(1, arrayLen(commandLine.command().arguments().argument()));
		assertEquals("directory", commandLine.command().arguments().argument()[1].argumentName().getText());
		assertEquals("blah", commandLine.command().arguments().argument()[1].value().getText());

		parse = parser.parse("dir directory=/ recurse=false");
		commandLine = parse.tree;
		messages = parse.messages;
		debug(parse.stringtree);
		debug(parse.infostring);
		debug(messages);
		assertEquals(0, messages.size());
		assertTrue(isNull(commandLine.namespace()));
		assertEquals("dir", commandLine.command().commandName().getText());
		assertEquals(2, arrayLen(commandLine.command().arguments().argument()));
		assertEquals("directory", commandLine.command().arguments().argument()[1].argumentName().getText());
		assertEquals("/", commandLine.command().arguments().argument()[1].value().getText());
		assertEquals("recurse", commandLine.command().arguments().argument()[2].argumentName().getText());
		assertEquals("false", commandLine.command().arguments().argument()[2].value().getText());

	}

	public void function testParseNamespace()  {
		parse = parser.parse("cfdistro");
		commandLine = parse.tree;
		messages = parse.messages;
		assertEquals("cfdistro", commandLine.namespace().getText());
		assertEquals("<missing commandname>", commandLine.command().getText());
		assertEquals(0, commandLine.command().arguments().argument().size());

		parse = parser.parse("cfdistro dependency");
		commandLine = parse.tree;
		messages = parse.messages;
		assertEquals("cfdistro", commandLine.namespace().getText());
		assertEquals("dependency", commandLine.command().getText());
		assertEquals(0, commandLine.command().arguments().argument().size());

	}

	public void function testParseNamespaceCommand()  {
		parse = parser.parse("cfdistro dependency");
		commandLine = parse.tree;
		messages = parse.messages;
		assertEquals("cfdistro", commandLine.namespace().getText());
		assertEquals("dependency", commandLine.command().getText());
		assertEquals(0, commandLine.command().arguments().argument().size());

	}
}