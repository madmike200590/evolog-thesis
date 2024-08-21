import org.junit.jupiter.api.Test;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class PlaygroundTests {

	@Test
	void matchers() {
		String someXmlSnippet = "<haha><huhu foo=\"bar\" bla=\"blubb\">baz</huhu></haha>";
		//String xmlTagOpenRegex = "<\\w+( (\\w=\"\\w\"))*>";
		String xmlTagOpenRegex = "(<(\\w+)( (\\w+=\"\\w+\"))*>)";
		String xmlTagCloseRegex = "(</\\w+>)";
		Matcher matcher = Pattern.compile(xmlTagOpenRegex).matcher(someXmlSnippet);
		System.out.println("Found " + matcher.groupCount() + " groups");
		while(matcher.find()) {
			for (int i = 1; i <= matcher.groupCount(); i++) {
				System.out.printf("match = %s, from=%d, to=%d\n", matcher.group(1), matcher.start(1), matcher.end(1));
				System.out.println(someXmlSnippet.substring(matcher.start(1), matcher.end(1)));
			}
		}
	}
}
