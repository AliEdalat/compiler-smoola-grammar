grammar Smoola;
	@members{
	   void print(Object obj){
	        System.out.println(obj);
	   }
	}

	@header {
		import ast.node.Program;
		import ast.node.declaration.*;
		import ast.node.expression.*;
		import ast.VisitorImpl;
		import symbolTable.*;
	}
	program:
		program1[new SymbolTable()]
		{
			VisitorImpl visitor = new VisitorImpl();
			$program1.synthesized_type.accept(visitor);
		}
	;

    program1 [SymbolTable inherited_table] returns [Program synthesized_type]:
        {
        	$synthesized_type = new Program();
        }
        mainClass[new SymbolTable(inherited_table)]
        {
        	$synthesized_type.setMainClass($mainClass.synthesized_type);
        	try {
        		$inherited_table.put(new SymbolTableClassItem($mainClass.synthesized_name, $mainClass.synthesized_table));
        	}
        	catch(ItemAlreadyExistsException e) {	
        	}
        }
        (
        	classDeclaration[new SymbolTable(inherited_table)]
        	{
        		$synthesized_type.addClass($classDeclaration.synthesized_type);
        		try{
        			$inherited_table.put(new SymbolTableClassItem($classDeclaration.synthesized_name, $classDeclaration.synthesized_table));
        		}catch(ItemAlreadyExistsException e){
        			System.out.printf("Line:%d:‫‪Redefinition of class ‬‬%s\n", 4, $classDeclaration.synthesized_name);
        		}
        	}
        )* EOF
    ;
    mainClass [SymbolTable inherited_table] returns [ClassDeclaration synthesized_type, SymbolTable synthesized_table, String synthesized_name]:
        // name should be checked later
        'class' name = ID '{' 'def' ID '(' ')' ':' 'int' '{'  statements 'return' expression ';' '}' '}' {$synthesized_type = new ClassDeclaration(new Identifier($name.getText()), null); $synthesized_name = $name.getText(); $synthesized_table = $inherited_table;}
    ;
    classDeclaration [SymbolTable inherited_table] returns [ClassDeclaration synthesized_type, SymbolTable synthesized_table, String synthesized_name]:
        'class' name = ID ('extends' father_name = ID)? '{' (varDeclaration)* (methodDeclaration)* '}' {$synthesized_type = new ClassDeclaration(new Identifier($name.getText()), new Identifier((($father_name != null) ? $father_name.getText() : ""))); $synthesized_name = $name.getText(); $synthesized_table = $inherited_table;}
    ;
    varDeclaration:
        'var' ID ':' type ';'
    ;
    methodDeclaration:
        'def' ID ('(' ')' | ('(' ID ':' type (',' ID ':' type)* ')')) ':' type '{'  varDeclaration* statements 'return' expression ';' '}'
    ;
    statements:
        (statement)*
    ;
    statement:
        statementBlock |
        statementCondition |
        statementLoop |
        statementWrite |
        statementAssignment
    ;
    statementBlock:
        '{'  statements '}'
    ;
    statementCondition:
        'if' '('expression')' 'then' statement ('else' statement)?
    ;
    statementLoop:
        'while' '(' expression ')' statement
    ;
    statementWrite:
        'writeln(' expression ')' ';'
    ;
    statementAssignment:
        expression ';'
    ;

    expression:
		expressionAssignment
	;

    expressionAssignment:
		expressionOr '=' expressionAssignment
	    |	expressionOr
	;

    expressionOr:
		expressionAnd expressionOrTemp
	;

    expressionOrTemp:
		'||' expressionAnd expressionOrTemp
	    |
	;

    expressionAnd:
		expressionEq expressionAndTemp
	;

    expressionAndTemp:
		'&&' expressionEq expressionAndTemp
	    |
	;

    expressionEq:
		expressionCmp expressionEqTemp
	;

    expressionEqTemp:
		('==' | '<>') expressionCmp expressionEqTemp
	    |
	;

    expressionCmp:
		expressionAdd expressionCmpTemp
	;

    expressionCmpTemp:
		('<' | '>') expressionAdd expressionCmpTemp
	    |
	;

    expressionAdd:
		expressionMult expressionAddTemp
	;

    expressionAddTemp:
		('+' | '-') expressionMult expressionAddTemp
	    |
	;

        expressionMult:
		expressionUnary expressionMultTemp
	;

    expressionMultTemp:
		('*' | '/') expressionUnary expressionMultTemp
	    |
	;

    expressionUnary:
		('!' | '-') expressionUnary
	    |	expressionMem
	;

    expressionMem:
		expressionMethods expressionMemTemp
	;

    expressionMemTemp:
		'[' expression ']'
	    |
	;
	expressionMethods:
	    expressionOther expressionMethodsTemp
	;
	expressionMethodsTemp:
	    '.' (ID '(' ')' | ID '(' (expression (',' expression)*) ')' | 'length') expressionMethodsTemp
	    |
	;
    expressionOther:
		CONST_NUM
        |	CONST_STR
        |   'new ' 'int' '[' CONST_NUM ']'
        |   'new ' ID '(' ')'
        |   'this'
        |   'true'
        |   'false'
        |	ID
        |   ID '[' expression ']'
        |	'(' expression ')'
	;
	type:
	    'int' |
	    'boolean' |
	    'string' |
	    'int' '[' ']' |
	    ID
	;
    CONST_NUM:
		[0-9]+
	;

    CONST_STR:
		'"' ~('\r' | '\n' | '"')* '"'
	;
    NL:
		'\r'? '\n' -> skip
	;

    ID:
		[a-zA-Z_][a-zA-Z0-9_]*
	;

    COMMENT:
		'#'(~[\r\n])* -> skip
	;

    WS:
    	[ \t] -> skip
    ;