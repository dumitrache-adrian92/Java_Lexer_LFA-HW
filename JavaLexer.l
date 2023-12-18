%{
#include <bits/stdc++.h>
using namespace std;
extern "C" int yylex();

class Class
{
 public:
    Class(string name) : name(name) {
        objectCount = 0;
    }

    string name;
    unsigned int objectCount;
    unordered_map<string, bool> attributes;
};

unordered_map<string, Class *> classes;
%}

class_keyword "class"
whitespace [ \t\n]+
letter [a-zA-Z]
digit [0-9]
underscore _
dollar_sign \$

class_first_char {letter}|{underscore}|{dollar_sign}
class_char {letter}|{digit}|{underscore}|{dollar_sign}
class_name {class_first_char}{class_char}+

start_line_comment "//"
start_block_comment "/*"
end_block_comment "*/"

%option stack
%s CLASS_DEFINITION
%x LINE_COMMENT
%x BLOCK_COMMENT

%%
{class_keyword} {BEGIN CLASS_DEFINITION;}

{start_line_comment} {
    yy_push_state(LINE_COMMENT);
}
<LINE_COMMENT>\n {yy_pop_state();}
<LINE_COMMENT>. { /* ignore */ }

{start_block_comment} {
    yy_push_state(BLOCK_COMMENT);
}
<BLOCK_COMMENT>{end_block_comment} {yy_pop_state();}
<BLOCK_COMMENT>. { /* ignore */}

<CLASS_DEFINITION>{whitespace} { /* ignore whitespace */ }
<CLASS_DEFINITION>{class_name}  {
    if (classes.find(yytext) != classes.end()) {
        cout << "Class already defined: " << yytext << endl;
        exit(1);
    }

    classes[yytext] = new Class(yytext);
    BEGIN(INITIAL);
}
<CLASS_DEFINITION>{digit}{class_char}+  {
    cout << "Invalid class name: " << yytext << endl;
    exit(1);
}

.|\n  {}
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
                if (!it2->second) {
                    cout << "Metodele 'get' si 'set' nu sunt implementate." << endl;
                    print = false;
                    break;
                }
            }

            if (print)
                cout << "Metodele 'get' si 'set' sunt implementate." << endl;
        }
    }
}