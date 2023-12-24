/* Dumitrache Adrian-George 334CC */

%{
#include <bits/stdc++.h>
using namespace std;
extern "C" int yylex();

bool isPublicClassDeclared = false;

enum AccessModifier {
    PUBLIC,
    PRIVATE
};

bool isPublic;
string currentClass;
AccessModifier currentDefinitionAccessModifier;
string currentDefinitionType;
string currentDefinitionName;
bool isArray;
int arraySize;

class Attribute
{
 public:
    Attribute(string name, string type) : name(name), type(type) {
        hasSet = false;
        hasGet = false;
        isArray = false;
        initialized = false;
    }
    string name;
    string type;
    bool hasSet;
    bool hasGet;
    bool isArray;
    bool initialized;
    int arraySize;
};

class Class
{
 public:
    Class(string name) : name(name) {
        objectCount = 0;
        defined = false;
        isPublic = false;
    }

    string name;
    bool defined;
    bool isPublic;
    unsigned int objectCount;
    unordered_map<string, Attribute *> attributes;
};

class MainMethod
{
    public:
        MainMethod() {
        }

        unordered_map<string, Attribute *> attributes;
};

bool isPrimitive(string type) {
    return type == "int" || type == "float" || type == "double" || type == "char" || type == "boolean" || type == "byte" || type == "short" || type == "long";
}


unordered_map<string, Class *> classes;
MainMethod *mainMethod = new MainMethod();
%}

class_keyword "class"
public_keyword "public"
private_keyword "private"
extends_keyword "extends"
for_keyword "for"
new_keyword "new"
implements_keyword "implements"
static_keyword "static"
main_keyword "main"
void_keyword "void"
main_arg_type "String\[\]"
main_arg_name "args"

set "set"
get "get"

whitespace [ \t\n\r\f\v]+
possible_whitespace [ \t\n\r\f\v]*
letter [a-zA-Z]
digit [0-9]
underscore _
dollar_sign \$
open_brace \{
close_brace \}
equal_sign =
semicolon ;
open_parenthesis \(
close_parenthesis \)
open_square_bracket \[
close_square_bracket \]

public_static_void_main {public_keyword}{whitespace}{static_keyword}{whitespace}{void_keyword}{whitespace}{main_keyword}{possible_whitespace}{open_parenthesis}{possible_whitespace}{main_arg_type}{possible_whitespace}{main_arg_name}{possible_whitespace}{close_parenthesis}
integer [1-9]{digit}*

identifier_first_char {letter}|{underscore}|{dollar_sign}
identifier_char {letter}|{digit}|{underscore}|{dollar_sign}
identifier {identifier_first_char}{identifier_char}*

start_line_comment "//"
start_block_comment "/*"
end_block_comment "*/"

%option stack

/* after public class keyword, next token will be the class keyword */
%s PUBLIC_CLASS_START
/* after class definition, next token will be a class name*/
%s CLASS_START
/* after class name, next token will be an open brace or extends */
%s CLASS_NAME

%s INSIDE_CLASS
/* after public/private keyword, could be the start of a field definition or
 * method definition
 */
%s PUBLIC_INSIDE_CLASS
%s PRIVATE_INSIDE_CLASS
/* after type of definition */
%s TYPE
%s SETTER
%s GETTER
/* after type and name of definition */
%s VALUE_OR_ARGUMENTS
/* after type, name and = of definition */
%s FIELD_INIT


%s MAIN
%s PRIMITIVE_DECLARATION
%s OBJECT_DECLARATION_TYPE
%s OBJECT_DECLARATION_NAME
%s OBJECT_DECLARATION_INIT
%s OBJECT_DECLARATION_INIT_ARRAY
%s UNTIL_SEMICOLON
%s ASSIGNMENT_VARIABLE

%s FOR_START
%s FOR_ONE_LINE
%s FOR_LINES
%s FOR_ASSIGNMENT
%s NEW_OBJECT_IN_FOR

%s OTHER_IMBRICATION


%x LINE_COMMENT
%x BLOCK_COMMENT

%%
{start_line_comment} {
    yy_push_state(LINE_COMMENT);
}
<LINE_COMMENT>\n {yy_pop_state();}
<LINE_COMMENT>. { /* ignore */ }

{start_block_comment} {
    yy_push_state(BLOCK_COMMENT);
}
<BLOCK_COMMENT>{end_block_comment} {yy_pop_state();}
<BLOCK_COMMENT>.|\n { /* ignore */}


<INITIAL>{public_keyword} {
    if (isPublicClassDeclared) {
        cout << "Eroare: 2 sau mai multe clase publice detectate" << endl;
        exit(1);
    }

    isPublicClassDeclared = true;
    isPublic = true;
    BEGIN PUBLIC_CLASS_START;
}
<INITIAL>{class_keyword} { BEGIN CLASS_START; }

<PUBLIC_CLASS_START>{class_keyword} {BEGIN CLASS_START;}

<CLASS_START>{identifier}  {
    if (classes.find(yytext) != classes.end() && classes[yytext]->defined) {
        cout << "Clasa deja definita: " << yytext << endl;
        exit(1);
    }

    if (classes.find(yytext) == classes.end())
        classes[yytext] = new Class(yytext);
    classes[yytext]->defined = true;
    classes[yytext]->isPublic = isPublic;
    isPublic = false;
    currentClass = yytext;
    BEGIN(CLASS_NAME);
}

<CLASS_START>{digit}{identifier_char}+  {
    cout << "Nume invalid de clasa: " << yytext << endl;
    exit(1);
}

<CLASS_NAME>{open_brace} { BEGIN(INSIDE_CLASS); }
<CLASS_NAME>{extends_keyword}{whitespace}{identifier} { /* ignore */ }
<CLASS_NAME>{implements_keyword}{whitespace}{identifier} { /* ignore */ }

<INSIDE_CLASS>{public_static_void_main}{possible_whitespace}{open_brace} {
    if (!classes[currentClass]->isPublic) {
        cout << "Eroare: Metoda main declarata intr-o clasa ce nu este publica." << endl;
        exit(1);
    }
    yy_push_state(MAIN);

}
<INSIDE_CLASS>{open_brace} { yy_push_state(OTHER_IMBRICATION); }
<INSIDE_CLASS>{close_brace} { BEGIN(INITIAL); }
<INSIDE_CLASS>{public_keyword} {
    currentDefinitionAccessModifier = PUBLIC;
    yy_push_state(PUBLIC_INSIDE_CLASS);
}
<INSIDE_CLASS>{private_keyword} {
    currentDefinitionAccessModifier = PRIVATE;
    yy_push_state(PRIVATE_INSIDE_CLASS);
}
<INSIDE_CLASS>.|\n { /* ignore */ }

<MAIN>{identifier}/{whitespace}{identifier}{possible_whitespace}{semicolon} {
    if (isPrimitive(yytext)) {
        yy_push_state(PRIMITIVE_DECLARATION);
    }  else {
        currentDefinitionType = yytext;
        yy_push_state(OBJECT_DECLARATION_TYPE);
    }
}
<MAIN>{identifier}/{whitespace}{identifier}{possible_whitespace}{equal_sign} {
    if (isPrimitive(yytext)) {
        yy_push_state(PRIMITIVE_DECLARATION);
    } else {
        currentDefinitionType = yytext;
        yy_push_state(OBJECT_DECLARATION_TYPE);
    }
}
<MAIN>{identifier}/{possible_whitespace}{open_square_bracket}{close_square_bracket}{whitespace}{identifier}{possible_whitespace}{equal_sign} {
    isArray = true;
    if (isPrimitive(yytext)) {
        yy_push_state(PRIMITIVE_DECLARATION);
    } else {
        currentDefinitionType = yytext;
        yy_push_state(OBJECT_DECLARATION_TYPE);
    }
}
<MAIN>{identifier}/{possible_whitespace}{open_square_bracket}{close_square_bracket}{whitespace}{identifier} {
    isArray = true;
    if (isPrimitive(yytext)) {
        yy_push_state(PRIMITIVE_DECLARATION);
    } else {
        currentDefinitionType = yytext;
        yy_push_state(OBJECT_DECLARATION_TYPE);
    }
}


<OBJECT_DECLARATION_TYPE>{open_square_bracket}{close_square_bracket} { /* ignore */ }

<OBJECT_DECLARATION_TYPE>{identifier} {

    currentDefinitionName = yytext;
    mainMethod->attributes[currentDefinitionName] = new Attribute(currentDefinitionName, currentDefinitionType);
    mainMethod->attributes[currentDefinitionName]->isArray = isArray;

    BEGIN(OBJECT_DECLARATION_NAME);
}

<OBJECT_DECLARATION_NAME>{semicolon} {
    yy_pop_state();
}

<OBJECT_DECLARATION_NAME>{equal_sign}{possible_whitespace}{new_keyword} {
    BEGIN(OBJECT_DECLARATION_INIT);
}

<OBJECT_DECLARATION_INIT>{identifier}{possible_whitespace}{open_square_bracket}/{integer}{close_square_bracket} {
    BEGIN(OBJECT_DECLARATION_INIT_ARRAY);
}
<OBJECT_DECLARATION_INIT>{identifier} {
    if (yytext != currentDefinitionType) {
        cout << "Eroare: Tipul variabilei nu corespunde cu tipul obiectului instantiat (" << currentDefinitionType << "vs. " << yytext << ")" << endl;
        exit(1);
    }

    if (classes.find(yytext) == classes.end()) {
        classes[yytext] = new Class(yytext);
    }

    if (mainMethod->attributes.find(currentDefinitionName) != mainMethod->attributes.end() && !mainMethod->attributes[currentDefinitionName]->initialized) {
        classes[yytext]->objectCount++;
    }

    mainMethod->attributes[currentDefinitionName]->initialized = true;

    BEGIN(UNTIL_SEMICOLON);
}

<OBJECT_DECLARATION_INIT_ARRAY>{integer} {
    mainMethod->attributes[currentDefinitionName]->arraySize = stoi(yytext);

    BEGIN(UNTIL_SEMICOLON);
}

<UNTIL_SEMICOLON>{semicolon} {yy_pop_state();}
<UNTIL_SEMICOLON>. { /* ignore */ }


<PRIMITIVE_DECLARATION>{semicolon} { yy_pop_state(); }
<PRIMITIVE_DECLARATION>. {/* ignore */}

<MAIN>{identifier}/{possible_whitespace}{equal_sign} {
    if (mainMethod->attributes.find(yytext) != mainMethod->attributes.end()) {
        currentDefinitionName = yytext;
        yy_push_state(ASSIGNMENT_VARIABLE);
    }
}

<ASSIGNMENT_VARIABLE>{equal_sign}{possible_whitespace}{new_keyword} {
    BEGIN(OBJECT_DECLARATION_INIT);
}

<MAIN>{for_keyword}{possible_whitespace}{open_parenthesis} {
    yy_push_state(FOR_START);
}

<FOR_START>. { /* ignore */ }
<FOR_START>{close_parenthesis} { BEGIN(FOR_ONE_LINE); }
<FOR_START>{close_parenthesis}{possible_whitespace}{open_brace} { BEGIN(FOR_LINES); }

<FOR_ONE_LINE>{identifier}{possible_whitespace}{open_square_bracket}{identifier}{close_square_bracket}{possible_whitespace}{equal_sign} {
    currentDefinitionName = yytext;
    cout << "Array assignment" << endl;
    yy_push_state(FOR_ASSIGNMENT);
}
<FOR_ONE_LINE>{semicolon} { yy_pop_state(); }
<FOR_ONE_LINE>. { /* ignore */ }

<FOR_LINES>{identifier}/{possible_whitespace}{open_square_bracket}{identifier}{close_square_bracket}{possible_whitespace}{equal_sign} {
    currentDefinitionName = yytext;
    yy_push_state(FOR_ASSIGNMENT);
}
<FOR_LINES>{close_brace} { yy_pop_state(); }
<FOR_LINES>. { /* ignore */ }

<FOR_ASSIGNMENT>{possible_whitespace}{open_square_bracket}{identifier}{close_square_bracket}{possible_whitespace}{equal_sign}{possible_whitespace}{new_keyword} {BEGIN(NEW_OBJECT_IN_FOR); }
<NEW_OBJECT_IN_FOR>{identifier} {
    if (classes.find(yytext) == classes.end()) {
        classes[yytext] = new Class(yytext);
    }

    classes[yytext]->objectCount += mainMethod->attributes[currentDefinitionName]->arraySize;

    yy_pop_state();
}

<MAIN>{open_brace} { yy_push_state(OTHER_IMBRICATION); }
<MAIN>{close_brace} { yy_pop_state(); }
<MAIN>.|\n { /* ignore */ }

<PUBLIC_INSIDE_CLASS>{identifier} {
    currentDefinitionType = yytext;
    BEGIN(TYPE);
}

<PRIVATE_INSIDE_CLASS>{identifier} {
    currentDefinitionType = yytext;
    BEGIN(TYPE);
}

<TYPE>{open_parenthesis} {
    yy_pop_state();
}

<TYPE>{set}/{identifier}{possible_whitespace}{open_parenthesis} {
    currentDefinitionName = yytext;
    BEGIN(SETTER);
}

<TYPE>{get}/{identifier}{possible_whitespace}{open_parenthesis} {
    currentDefinitionName = yytext;
    BEGIN(GETTER);
}

<TYPE>{identifier} {
    currentDefinitionName = yytext;

    BEGIN(VALUE_OR_ARGUMENTS);
}

<TYPE>{open_square_bracket}{integer}{close_square_bracket} {
    isArray = true;
}

<TYPE>{open_square_bracket}{close_square_bracket} {
    isArray = true;
}

<SETTER>{identifier} {
    currentDefinitionName += yytext;

    string attributeName = yytext;
    // make first letter lowercase
    attributeName[0] = tolower(attributeName[0]);

    if (classes[currentClass]->attributes.find(attributeName) != classes[currentClass]->attributes.end()) {
        if (currentDefinitionType == "void")
            classes[currentClass]->attributes[attributeName]->hasSet = true;
    }

    BEGIN(VALUE_OR_ARGUMENTS);
}

<GETTER>{identifier} {
    currentDefinitionName += yytext;

    string attributeName = yytext;
    // make first letter lowercase
    attributeName[0] = tolower(attributeName[0]);

    if (classes[currentClass]->attributes.find(attributeName) != classes[currentClass]->attributes.end()) {
        if (classes[currentClass]->attributes[attributeName]->type == currentDefinitionType)
            classes[currentClass]->attributes[attributeName]->hasGet = true;
    }

    BEGIN(VALUE_OR_ARGUMENTS);
}

<VALUE_OR_ARGUMENTS>{open_parenthesis} {
    // we don't actually care about methods that are not getters or setters

    yy_pop_state();
}
<VALUE_OR_ARGUMENTS>{semicolon} {
    // field definition
    classes[currentClass]->attributes[currentDefinitionName] = new Attribute(currentDefinitionName, currentDefinitionType);
    classes[currentClass]->attributes[currentDefinitionName]->isArray = isArray;
    isArray = false;
    yy_pop_state();
}
<VALUE_OR_ARGUMENTS>{open_square_bracket}{integer}{close_square_bracket} {
    isArray = true;
}
<VALUE_OR_ARGUMENTS>{open_square_bracket}{close_square_bracket} {
    isArray = true;
}
<VALUE_OR_ARGUMENTS>{equal_sign} {
    BEGIN(FIELD_INIT);
}
<VALUE_OR_ARGUMENTS>. { yy_pop_state(); }

<FIELD_INIT>; {
    yy_pop_state();
}
<FIELD_INIT>. {
    /* ignore */
}


<OTHER_IMBRICATION>{close_brace} { yy_pop_state(); }
<OTHER_IMBRICATION>{open_brace} { yy_push_state(OTHER_IMBRICATION); }
<OTHER_IMBRICATION>.|\n { /* ignore */ }


{whitespace} { /* ignore whitespace */ }

. {
    cout << "Invalid token: " << yytext << endl;
    cout << "Invalid token" << endl;
    exit(1);
}
%%

int main(int argc, char **argv)
{
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        cout << "File not found" << endl;
        exit(1);
    }

    yylex();

    // print number of classes and their names
    cout << "Clase " << classes.size() << ": ";

    for (auto it = classes.begin(); it != classes.end(); it++) {
        cout << it->first;

        if (next(it) != classes.end())
            cout << ", ";
        else
            cout << endl;
    }

    for (auto it = classes.begin(); it != classes.end(); it++) {
        cout << "Obiecte " << it->first << ": " << it->second->objectCount << endl;
    }

    for (auto it = classes.begin(); it != classes.end(); it++) {
        cout << it->first << ": ";

        if (it->second->attributes.size() == 0) {
            cout << "Nu exista atribute" << endl;
        } else {
            bool print = true;
            for (auto it2 = it->second->attributes.begin(); it2 != it->second->attributes.end(); it2++) {
                if (!it2->second->hasGet) {
                    cout << "Metoda 'get' nu este implementata pentru toate atributele." << endl;
                    print = false;
                    break;
                }
            }

            for (auto it2 = it->second->attributes.begin(); it2 != it->second->attributes.end(); it2++) {
                if (!it2->second->hasGet) {
                    cout << "Metoda 'set' nu este implementata pentru toate atributele." << endl;
                    print = false;
                    break;
                }
            }

            if (print)
                cout << "Metodele 'get' si 'set' sunt implementate." << endl;
        }
    }
}
