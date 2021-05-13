# Computer Architecture: Project 3 
# Purpose / Goal
A basic calculator that takes into account the standard "PEMDAS" rule. 
# Usage
``` $> jag3.out <operation> ```  
where operation is defined as:
``` operation = <operand> <arithmetic operation> <operand> , ... ```
  
For Example: 
``` $> jag3.out 3+2+3*3/3^3 ```

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
The Design document can be found [here](https://cooperunion-my.sharepoint.com/:w:/g/personal/aliza_meller_cooper_edu/EQxlyZTsLDBDncoUJjVM430B47V6FMSasxTC2jTI3mmsPw?e=fhFgLr)
