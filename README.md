# Computer Architecture: Project 3 
# Purpose / Goal
A basic calculator that takes into account the standard "PEMDAS" rule. 
# Usage
``` $> jag3.out <operation> ```  
where operation is defined as:
``` operation = <operand> <arithmetic operation> <operand> , ... ```
  
For Example: 
``` $> jag3.out "((2+2+2+2+2-0.5-1.5)/2*0.5)^5" ```

Output:

``` 2 2 + 2 + 2 + 2 + 0.5 - 1.5 - 2 / 0.5 * 5 ^  ``` 

``` 32.000000 ```

Note:
- negative numbers are NOT supported
- floats ARE supported
- expression must be wrapped in double quotes (")
- there cannot be any spaces between characters in the argument

# Installation Method
1. Download the assembly file from GitHub using curl:
```bash
curl https://raw.githubusercontent.com/alizameller/Project3/main/jag3.s --output jag3.s
```
2. Download the Makefile from GitHub using curl: 
```bash
curl https://raw.githubusercontent.com/alizameller/Project3/main/Makefile --output Makefile
```
3. Run the Makefile in the directory downloaded: 
```bash
make
```
4. Run the exectutable generated followed by the operation: 
```bash
./jag3.out <operation>
```

# Design Document
The Design document can be found [here](https://github.com/alizameller/Project3/files/6476386/Design.Document.-.Project.3.pdf)

