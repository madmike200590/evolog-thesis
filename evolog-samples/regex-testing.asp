teststring("<haha><huhu foo=\"bar\" bla=\"blubb\">baz</huhu></haha>").
xml_tag_open_regex("(<(\w+)( (\w+=\\"\w+\\"))*>)").

regex_match(MATCH, FROM, TO) :- teststring(STR), xml_tag_open_regex(REGEX), &regex_matches[REGEX, STR](MATCH, FROM, TO).