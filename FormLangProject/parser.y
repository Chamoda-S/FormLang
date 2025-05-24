%define parse.error verbose
%debug
%start form_spec


%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void); 
int yydebug = 1;
extern int yylineno;
  
char html[20000] = ""; 
%}

%union {
    int num;
    char *str;
}
                           
%token <str> FORM SECTION FIELD IDENTIFIER STRING_LITERAL
%token COLON SEMICOLON LBRACE RBRACE

%type <str> form_body section field_list field

%%

form_spec:
     FORM IDENTIFIER LBRACE form_body RBRACE {
          sprintf(html,
            "<!DOCTYPE html>\n"
            "<html>\n"
            "<head>\n"
            "  <meta charset=\"UTF-8\">\n"
            "  <title>%s</title>\n"
            "  <link rel=\"stylesheet\" href=\"styles.css\">\n"
            "</head>\n"
            "<body>\n"
            "<form name=\"%s\">\n"
            "<h2 class=\"form-title\">Registration Form</h2>\n"
            "%s"
            "<input type=\"submit\" value=\"Submit\">\n"
            "</form>\n"
            "<div id=\"successMessage\" class=\"success-message\" style=\"display:none;\">Form submitted successfully!</div>\n"
            "<script>\n"
            "  document.querySelector('form').addEventListener('submit', function(event) {\n"
            "    event.preventDefault();\n"
            "    document.getElementById('successMessage').style.display = 'block';\n"
            "    this.reset();\n"
            "    const removeBtn = document.getElementById('removeFile');\n"
            "    if (removeBtn) removeBtn.style.display = 'none';\n"
            "  });\n"
            "  const fileInput = document.querySelector('input[type=\"file\"]');\n"
            "  const removeBtn = document.getElementById('removeFile');\n"
            "  if (fileInput && removeBtn) {\n"
            "    fileInput.addEventListener('change', function() {\n"
            "      if (fileInput.files.length > 0) {\n"
            "        removeBtn.style.display = 'inline';\n"
            "      } else {\n"
            "        removeBtn.style.display = 'none';\n"
            "      }\n"
            "    });\n"
            "    removeBtn.addEventListener('click', function(e) {\n"
            "      e.preventDefault();\n"
            "      fileInput.value = \"\";\n"
            "      removeBtn.style.display = 'none';\n"
            "    });\n"
            "  }\n"
            "</script>\n"
            "</body>\n"
            "</html>\n",
            $2, $2, $4);
          printf("%s", html);
          free($2); free($4);
     }
;

form_body:
   form_body section {
        char *buf = malloc(strlen($1) + strlen($2) + 1);
        strcpy(buf, $1); strcat(buf, $2);
        $$ = buf;
        free($1); free($2);
   }
   | section { $$ = $1; }
;

section:
    SECTION STRING_LITERAL LBRACE field_list RBRACE {
        $$ = $4;
        free($2);
    }
;

field_list:
   field_list field {
        char *buf = malloc(strlen($1) + strlen($2) + 1);
        strcpy(buf, $1); strcat(buf, $2);
        $$ = buf;
        free($1); free($2);
   }
   | field { $$ = $1; }
;

field:
    FIELD IDENTIFIER COLON IDENTIFIER SEMICOLON {
        char *buf = malloc(2048);

        if (strcmp($2, "fullName") == 0)
            sprintf(buf, "<label>Full Name: <input type=\"text\" name=\"%s\" required pattern=\"[A-Za-z ]+\" title=\"Only letters and spaces allowed\"></label><br>\n", $2);
        else if (strcmp($2, "email") == 0)
            sprintf(buf, "<label>Email: <input type=\"email\" name=\"%s\" required></label><br>\n", $2);
        else if (strcmp($2, "age") == 0)
            sprintf(buf, "<label>Age: <input type=\"number\" name=\"%s\" min=\"1\" required></label><br>\n", $2);
        else if (strcmp($2, "phoneNumber") == 0)
            sprintf(buf, "<label>Phone Number: <input type=\"tel\" name=\"%s\" required></label><br>\n", $2);
        else if (strcmp($2, "gender") == 0)
            sprintf(buf,
                "<label>Gender:</label>\n"
                "<input type=\"radio\" name=\"%s\" value=\"Male\"> Male<br>\n"
                "<input type=\"radio\" name=\"%s\" value=\"Female\"> Female<br><br>\n", $2, $2);
        else if (strcmp($2, "address") == 0)
            sprintf(buf, "<label>Address: <textarea name=\"%s\" required></textarea></label><br>\n", $2);
        else if (strcmp($2, "interests") == 0)
            sprintf(buf,
                "<label>Fields of Interest:</label>\n"
                "<input type=\"checkbox\" name=\"%s[]\" value=\"Science\"> Science<br>\n"
                "<input type=\"checkbox\" name=\"%s[]\" value=\"Mathematics\"> Mathematics<br>\n"
                "<input type=\"checkbox\" name=\"%s[]\" value=\"Literature\"> Literature<br>\n"
                "<input type=\"checkbox\" name=\"%s[]\" value=\"Music\"> Music<br>\n"
                "<input type=\"checkbox\" name=\"%s[]\" value=\"Designing\"> Designing<br><br><br>\n", $2, $2, $2, $2, $2);
        else if (strcmp($2, "dateOfBirth") == 0)
            sprintf(buf, "<label>Date of Birth: <input type=\"date\" name=\"%s\" required></label><br>\n", $2);
        else if (strcmp($2, "maritalStatus") == 0)
            sprintf(buf,
                "<label>Marital Status:</label>\n"
                "<input type=\"radio\" name=\"%s\" value=\"Single\"> Single<br>\n"
                "<input type=\"radio\" name=\"%s\" value=\"Married\"> Married<br>\n"
                "<input type=\"radio\" name=\"%s\" value=\"Widowed\"> Widowed<br><br>\n", $2, $2, $2);
        else if (strcmp($2, "country") == 0)
            sprintf(buf,
                "<label>Country:\n"
                "<select name=\"%s\" required>\n"
                "  <option value=\"\">--Select Country--</option>\n"
                "  <option value=\"Sri Lanka\">Sri Lanka</option>\n"
                "  <option value=\"India\">India</option>\n"
                "  <option value=\"Britain\">Britain</option>\n"
                "  <option value=\"United States of America\">United States of America</option>\n"
                "  <option value=\"Denmark\">Denmark</option>\n"
                "  <option value=\"France\">France</option>\n"
                "</select></label><br>\n", $2);
        else if (strcmp($2, "password") == 0)
            sprintf(buf, "<label>Password: <input type=\"password\" name=\"%s\" required pattern=\"(?=.*[a-z])(?=.*[A-Z])(?=.*[^a-zA-Z0-9]).{6,12}\"></label><br>\n", $2);
        else if (strcmp($2, "profilePicture") == 0)
            sprintf(buf,
                "<label>Profile Picture: \n"
                "<input type=\"file\" name=\"%s\" id=\"fileInput\" required>\n"
                "<span id=\"removeFile\" class=\"remove-file\" style=\"displ ay:none; float: right;\">&times;</span></label><br>\n", $2);
        else
            sprintf(buf, "<!-- Unknown type for %s -->\n", $2);

        $$ = buf;
        free($2); free($4);
    }
;

%%

void yyerror(const char *s) {
     fprintf(stderr, "Parse error at line %d: %s\n", yylineno, s);
}

int main() {
    yydebug = 1;
    return yyparse();
}
