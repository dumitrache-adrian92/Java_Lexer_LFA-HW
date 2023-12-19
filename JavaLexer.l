%{
#include <bits/stdc++.h>
using namespace std;
extern "C" int yylex();

bool isPublicClassDeclared = false;

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
public_keyword "public"
whitespace [ \t\n\r\f\v]+
letter [a-zA-Z]
digit [0-9]
underscore _
dollar_sign \$
open_brace \{
close_brace \}

class_first_char {letter}|{underscore}|{dollar_sign}
class_char {letter}|{digit}|{underscore}|{dollar_sign}
class_name {class_first_char}{class_char}+

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

<CLASS_START>{class_name}  {
    if (classes.find(yytext) != classes.end()) {
        cout << "Class already defined: " << yytext << endl;
        exit(1);
    }

    classes[yytext] = new Class(yytext);
    BEGIN(CLASS_NAME);
}

<CLASS_START>{digit}{class_char}+  {
    cout << "Invalid class name: " << yytext << endl;
    exit(1);
}

<CLASS_NAME>{open_brace} { BEGIN(INSIDE_CLASS); }

<INSIDE_CLASS>{open_brace} { yy_push_state(OTHER_IMBRICATION); }
<INSIDE_CLASS>{close_brace} { BEGIN(INITIAL); }
<INSIDE_CLASS>.|\n { /* ignore */ }

<OTHER_IMBRICATION>{close_brace} { yy_pop_state(); }
<OTHER_IMBRICATION>{open_brace} { yy_push_state(OTHER_IMBRICATION); }
<OTHER_IMBRICATION>.|\n { /* ignore */ }


{whitespace} { /* ignore whitespace */ }

. {
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