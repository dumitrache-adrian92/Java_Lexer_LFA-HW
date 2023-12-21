%{
#include <bits/stdc++.h>
using namespace std;
extern "C" int yylex();

bool isPublicClassDeclared = false;

enum AccessModifier {
    PUBLIC,
    PRIVATE
};

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
    }
    string name;
    string type;
    bool hasSet;
    bool hasGet;
    bool isArray;
    int arraySize;
};

class Class
{
 public:
    Class(string name) : name(name) {
        objectCount = 0;
        defined = false;
    }

    string name;
    bool defined;
    unsigned int objectCount;
    unordered_map<string, Attribute *> attributes;
};

unordered_map<string, Class *> classes;
%}

class_keyword "class"
public_keyword "public"
private_keyword "private"
extends_keyword "extends"
implements_keyword "implements"

whitespace [ \t\n\r\f\v]+
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
/* after type and name of definition */
%s VALUE_OR_ARGUMENTS
/* after type, name and = of definition */
%s FIELD_INIT

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
    BEGIN PUBLIC_CLASS_START;
}
<INITIAL>{class_keyword} { BEGIN CLASS_START; }

<PUBLIC_CLASS_START>{class_keyword} {BEGIN CLASS_START;}

<CLASS_START>{identifier}  {
    if (classes.find(yytext) != classes.end()) {
        cout << "Class already defined: " << yytext << endl;
        exit(1);
    }

    classes[yytext] = new Class(yytext);
    classes[yytext]->defined = true;
    currentClass = yytext;
    BEGIN(CLASS_NAME);
}

<CLASS_START>{digit}{identifier_char}+  {
    cout << "Invalid class name: " << yytext << endl;
    exit(1);
}

<CLASS_NAME>{open_brace} { BEGIN(INSIDE_CLASS); }
<CLASS_NAME>{extends_keyword}{whitespace}{identifier} { /* ignore */ }
<CLASS_NAME>{implements_keyword}{whitespace}{identifier} { /* ignore */ }


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

<VALUE_OR_ARGUMENTS>{open_parenthesis} {
    // we know it's a method now

    // check if it's a getter
    if (currentDefinitionName.find("get") == 0) {
        // check if it's a getter for an attribute
        string attributeName = currentDefinitionName.substr(3);
        // make first letter lowercase
        attributeName[0] = tolower(attributeName[0]);

        if (classes[currentClass]->attributes.find(attributeName) != classes[currentClass]->attributes.end()) {
            if (classes[currentClass]->attributes[attributeName]->type == currentDefinitionType)
                classes[currentClass]->attributes[attributeName]->hasGet = true;
        }
    }

    // check if it's a setter
    if (currentDefinitionName.find("set") == 0) {
        // check if it's a setter for an attribute
        string attributeName = currentDefinitionName.substr(3);
        // make first letter lowercase
        attributeName[0] = tolower(attributeName[0]);

        if (classes[currentClass]->attributes.find(attributeName) != classes[currentClass]->attributes.end()) {
            if (currentDefinitionType == "void")
                classes[currentClass]->attributes[attributeName]->hasSet = true;
        }
    }

    // we don't actually care about methods otherwise

    yy_pop_state();
}
<VALUE_OR_ARGUMENTS>{semicolon} {
    // field definition
    classes[currentClass]->attributes[currentDefinitionName] = new Attribute(currentDefinitionName, currentDefinitionType);
    classes[currentClass]->attributes[currentDefinitionName]->isArray = isArray;
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
                if (!it2->second->hasGet || !it2->second->hasSet) {
                    cout << "Metodele 'get' si 'set' nu sunt implementate." << endl;
                    print = false;
                    break;
                }
            }

            if (print)
                cout << "Metodele 'get' si 'set' sunt implementate." << endl;
        }
    }

    for (auto it = classes.begin(); it != classes.end(); it++) {
        cout << it->first << ": ";

            for (auto it2 = it->second->attributes.begin(); it2 != it->second->attributes.end(); it2++) {
                cout << it2->second->type << " " << it2->second->name << "; ";
            }
        cout << endl;
    }
}
