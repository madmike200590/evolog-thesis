token_regex(tag_open, "(<(\w+)( (\w+=\\"\w+\\"))*>)").
token_regex(tag_close, "(</\w+>)").
opening_tag_name_regex("<(\w+)( (\w+=\\"\w+\\"))*>").
closing_tag_name_regex("</(\w+)>").
attribute_regex("(\w+=\\"\w+\\")").
attribute_name_regex("(\w+)=\\"\w+\\"").
attribute_value_regex("\w+=\\"(\w+)\\"").

line(0, "<graph directed=\"false\">").
line(1, "    <vertices>").
line(2, "        <vertex>a</vertex>").
line(3, "        <vertex>b</vertex>").
line(4, "        <vertex>c</vertex>").
line(5, "    </vertices>").
line(6, "    <edges>").
line(7, "        <edge>").
line(8, "            <source>a</source>").
line(9, "            <target>b</target>").
line(10, "        </edge>").
line(11, "        <edge>").
line(12, "            <source>b</source>").
line(13, "            <target>c</target>").
line(14, "        </edge>").
line(15, "        <edge>").
line(16, "            <source>c</source>").
line(17, "            <target>a</target>").
line(18, "        </edge>").
line(19, "    </edges>").
line(20, "</graph>").

token(t(TOK, VALUE), LINE_NO, FROM, TO) :- line(LINE_NO, LINE), token_regex(TOK, REGEX), &regex_matches[REGEX, LINE](VALUE, FROM, TO).

% Establish a token ordering
token_before(TOK1, TOK1_LINE_NO, TOK1_FROM, TOK1_TO, TOK2, TOK2_LINE_NO, TOK2_FROM, TOK2_TO) :- 
    token(TOK1, TOK1_LINE_NO, TOK1_FROM, TOK1_TO), 
    token(TOK2, TOK2_LINE_NO, TOK2_FROM, TOK2_TO), 
    TOK1_LINE_NO = TOK2_LINE_NO, TOK1_TO < TOK2_FROM.
token_before(TOK1, TOK1_LINE_NO, TOK1_FROM, TOK1_TO, TOK2, TOK2_LINE_NO, TOK2_FROM, TOK2_TO) :- 
    token(TOK1, TOK1_LINE_NO, TOK1_FROM, TOK1_TO), 
    token(TOK2, TOK2_LINE_NO, TOK2_FROM, TOK2_TO), 
    TOK1_LINE_NO < TOK2_LINE_NO.
token_not_predecessor(TOK1, TOK1_LINE_NO, TOK1_FROM, TOK1_TO, TOK2, TOK2_LINE_NO, TOK2_FROM, TOK2_TO) :-
    token_before(TOK1, TOK1_LINE_NO, TOK1_FROM, TOK1_TO, TOK_INT, TOK_INT_LINE_NO, TOK_INT_FROM, TOK_INT_TO),
    token_before(TOK_INT, TOK_INT_LINE_NO, TOK_INT_FROM, TOK_INT_TO, TOK2, TOK2_LINE_NO, TOK2_FROM, TOK2_TO).
token_predecessor(TOK1, TOK1_LINE_NO, TOK1_FROM, TOK1_TO, TOK2, TOK2_LINE_NO, TOK2_FROM, TOK2_TO) :-
    token_before(TOK1, TOK1_LINE_NO, TOK1_FROM, TOK1_TO, TOK2, TOK2_LINE_NO, TOK2_FROM, TOK2_TO),
    not token_not_predecessor(TOK1, TOK1_LINE_NO, TOK1_FROM, TOK1_TO, TOK2, TOK2_LINE_NO, TOK2_FROM, TOK2_TO).    
token_has_predecessor(TOK, TOK_LINE_NO, TOK_FROM, TOK_TO) :- 
    token_predecessor(_, _, _, _, TOK, TOK_LINE_NO, TOK_FROM, TOK_TO).
token_is_predecessor(TOK, TOK_LINE_NO, TOK_FROM, TOK_TO) :- 
    token_predecessor(TOK, TOK_LINE_NO, TOK_FROM, TOK_TO, _, _, _, _).        
token_first(TOK, TOK_LINE_NO, TOK_FROM, TOK_TO) :- 
    token(TOK, TOK_LINE_NO, TOK_FROM, TOK_TO), 
    not token_has_predecessor(TOK, TOK_LINE_NO, TOK_FROM, TOK_TO).
token_last(TOK, TOK_LINE_NO, TOK_FROM, TOK_TO) :-
    token(TOK, TOK_LINE_NO, TOK_FROM, TOK_TO), 
    not token_is_predecessor(TOK, TOK_LINE_NO, TOK_FROM, TOK_TO).    

% Extract tag names
tag_opening(TAG_NAME, t(tag_open, TOK_VALUE), LINE_NO, TAG_FROM, TAG_TO) :- 
    token(t(tag_open, TOK_VALUE), LINE_NO, TAG_FROM, TAG_TO),
    &regex_matches[TAG_NAME_REGEX, TOK_VALUE](TAG_NAME, _, _),
    opening_tag_name_regex(TAG_NAME_REGEX).
tag_closing(TAG_NAME, t(tag_close, TOK_VALUE), LINE_NO, TAG_FROM, TAG_TO) :- 
    token(t(tag_close, TOK_VALUE), LINE_NO, TAG_FROM, TAG_TO),
    &regex_matches[TAG_NAME_REGEX, TOK_VALUE](TAG_NAME, _, _),
    closing_tag_name_regex(TAG_NAME_REGEX). 

%% Extract attributes
tag_opening_attribute(TAG_NAME, t(tag_open, TOK_VALUE), LINE_NO, FROM, TO, attribute(NAME, VALUE)) :-
    tag_opening(TAG_NAME, t(tag_open, TOK_VALUE), LINE_NO, FROM, TO),
    &regex_matches[ATTRIBUTE_REGEX, TOK_VALUE](ATTRIBUTE_STR, _, _),
    attribute_regex(ATTRIBUTE_REGEX),
    &regex_matches[ATTRIBUTE_VALUE_REGEX, ATTRIBUTE_STR](VALUE, _, _), 
    attribute_value_regex(ATTRIBUTE_VALUE_REGEX),
    &regex_matches[ATTRIBUTE_NAME_REGEX, ATTRIBUTE_STR](NAME, _, _),
    attribute_name_regex(ATTRIBUTE_NAME_REGEX).

% We have an opening/closing tag pair if tag name is the same, 
% opening tag is before closing tag, and no opening tag of same name between.
tag_opening_between(TAG_NAME, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO) :- 
    tag_opening(TAG_NAME, OPEN_TOK, OPEN_LINE_NO, OPEN_FROM, OPEN_TO),
    tag_closing(TAG_NAME, CLOSE_TOK, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO),
    token(OPEN_TOK, OPEN_LINE_NO, OPEN_FROM, OPEN_TO),
    token(CLOSE_TOK, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO),
    token(INTM_OPEN_TOK, INTM_OPEN_LINE_NO, INTM_OPEN_FROM, INTM_OPEN_TO),
    tag_opening(TAG_NAME, INTM_OPEN_TOK, INTM_OPEN_LINE_NO, INTM_OPEN_FROM, INTM_OPEN_TO),
    token_before(OPEN_TOK, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, INTM_OPEN_TOK, INTM_OPEN_LINE_NO, INTM_OPEN_FROM, INTM_OPEN_TO),
    token_before(INTM_OPEN_TOK, INTM_OPEN_LINE_NO, INTM_OPEN_FROM, INTM_OPEN_TO, CLOSE_TOK, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO).
element(TAG_NAME, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO) :- 
    tag_opening(TAG_NAME, OPEN_TOK, OPEN_LINE_NO, OPEN_FROM, OPEN_TO),
    tag_closing(TAG_NAME, CLOSE_TOK, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO),
    token(OPEN_TOK, OPEN_LINE_NO, OPEN_FROM, OPEN_TO),
    token(CLOSE_TOK, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO),
    token_before(OPEN_TOK, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, CLOSE_TOK, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO),
    not tag_opening_between(TAG_NAME, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO).
element_attribute(TAG_NAME, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO, attribute(NAME, VALUE)) :-
    element(TAG_NAME, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO),
    tag_opening_attribute(TAG_NAME, t(tag_open, _), OPEN_LINE_NO, OPEN_FROM, OPEN_TO, attribute(NAME, VALUE)).
              
% Any string between two tags with no other opening or closing tags between is content
any_tag_opening_between(TAG_NAME, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO) :- 
    element(TAG_NAME, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO),
    token(OPEN_TOK, OPEN_LINE_NO, OPEN_FROM, OPEN_TO),
    token(CLOSE_TOK, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO),
    token_before(OPEN_TOK, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, t(tag_open, INTM_TOK), INTM_LINE_NO, INTM_FROM, INTM_TO),
    token_before(t(tag_open, INTM_TOK), INTM_LINE_NO, INTM_FROM, INTM_TO, CLOSE_TOK, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO).
any_tag_closing_between(TAG_NAME, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO) :- 
    element(TAG_NAME, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO),
    token(OPEN_TOK, OPEN_LINE_NO, OPEN_FROM, OPEN_TO),
    token(CLOSE_TOK, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO),
    token_before(OPEN_TOK, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, t(tag_close, INTM_TOK), INTM_LINE_NO, INTM_FROM, INTM_TO),
    token_before(t(tag_close, INTM_TOK), INTM_LINE_NO, INTM_FROM, INTM_TO, CLOSE_TOK, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO). 
any_tag_between(TAG_NAME, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO) :-
    any_tag_opening_between(TAG_NAME, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO),
    any_tag_closing_between(TAG_NAME, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO).       
terminal(TAG_NAME, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO) :- 
    element(TAG_NAME, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO),
    not any_tag_between(TAG_NAME, OPEN_LINE_NO, OPEN_FROM, OPEN_TO, CLOSE_LINE_NO, CLOSE_FROM, CLOSE_TO).

% Extract content between tags (currently assumes start and end tags to be on the same line)
element_text(ELEMENT_NAME, FROM_POS, TO_POS, TEXT) :-
    terminal(ELEMENT_NAME, LINE_NO, OPEN_FROM, OPEN_TO, LINE_NO, CLOSE_FROM, CLOSE_TO),
    line(LINE_NO, FULL_LINE),
    &string_substring[FULL_LINE, OPEN_TO, CLOSE_FROM](TEXT),
    FROM_POS = pos(LINE_NO, OPEN_FROM),
    TO_POS = pos(LINE_NO, CLOSE_TO).

% Derive parent elements
% An element encloses another if the opening and closing tag of the enclosed 
% element lie fully between opening and cloising tags of the enclosing element
element_encloses(ENC, ENC_POS_FROM, ENC_POS_TO, LOWER, LOWER_POS_FROM, LOWER_POS_TO) :- 
    element(LOWER, LOWER_OPEN_LINE_NO, LOWER_OPEN_FROM, LOWER_OPEN_TO, LOWER_CLOSE_LINE_NO, LOWER_CLOSE_FROM, LOWER_CLOSE_TO),
    element(ENC, ENC_OPEN_LINE_NO, ENC_OPEN_FROM, ENC_OPEN_TO, ENC_CLOSE_LINE_NO, ENC_CLOSE_FROM, ENC_CLOSE_TO),
    token(LOWER_OPEN_TOK, LOWER_OPEN_LINE_NO, LOWER_OPEN_FROM, LOWER_OPEN_TO),
    token(LOWER_CLOSE_TOK, LOWER_CLOSE_LINE_NO, LOWER_CLOSE_FROM, LOWER_CLOSE_TO),
    token(ENC_OPEN_TOK, ENC_OPEN_LINE_NO, ENC_OPEN_FROM, ENC_OPEN_TO),
    token(ENC_CLOSE_TOK, ENC_CLOSE_LINE_NO, ENC_CLOSE_FROM, ENC_CLOSE_TO),
    token_before(ENC_OPEN_TOK, ENC_OPEN_LINE_NO, ENC_OPEN_FROM, ENC_OPEN_TO, LOWER_OPEN_TOK, LOWER_OPEN_LINE_NO, LOWER_OPEN_FROM, LOWER_OPEN_TO),
    token_before(LOWER_CLOSE_TOK, LOWER_CLOSE_LINE_NO, LOWER_CLOSE_FROM, LOWER_CLOSE_TO, ENC_CLOSE_TOK, ENC_CLOSE_LINE_NO, ENC_CLOSE_FROM, ENC_CLOSE_TO),
    ENC_POS_FROM = pos(ENC_OPEN_LINE_NO, ENC_OPEN_FROM),
    ENC_POS_TO = pos(ENC_CLOSE_LINE_NO, ENC_CLOSE_TO),
    LOWER_POS_FROM = pos(LOWER_OPEN_LINE_NO, LOWER_OPEN_FROM),
    LOWER_POS_TO = pos(LOWER_CLOSE_LINE_NO, LOWER_CLOSE_TO).
% A element E1 is parent of element E2 if E1 encloses E2 and there is no other element that encloses E2 and is enclosed by E1.   
element_not_parent(E, E_POS_FROM, E_POS_TO, P, P_POS_FROM, P_POS_TO) :- 
    element_encloses(P, P_POS_FROM, P_POS_TO, E, E_POS_FROM, E_POS_TO),
    element_encloses(P, P_POS_FROM, P_POS_TO, I, I_POS_FROM, I_POS_TO),
    element_encloses(I, I_POS_FROM, I_POS_TO, E, E_POS_FROM, E_POS_TO).
element_parent(E, E_POS_FROM, E_POS_TO, P, P_POS_FROM, P_POS_TO) :- 
    element_encloses(P, P_POS_FROM, P_POS_TO, E, E_POS_FROM, E_POS_TO),
    not element_not_parent(E, E_POS_FROM, E_POS_TO, P, P_POS_FROM, P_POS_TO).
