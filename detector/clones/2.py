# Function to print binary number using recursion
def convertToBinary(n):
   if n > 1:
       convertToBinary(n//2)
   print(n % 2,end = '')

def main1():
    # Comment
    for i in range(1, 101):
        if i % 15 == 0:
            print("FizzBuzz")
        elif i % 3 == 0:
            print("Fizz")
        elif i % 5 == 0:
            print("Buzz")
        else:
            print(i)

# decimal number
dec = 34

convertToBinary(dec)
print()

def main2():
    for i in range(1, 101):
        # Comment
        if i % 15 == 0:
            print("FizzBuzz")
        elif i % 3 == 0:
            print("Fizz")
        elif i % 5 == 0:
            print("Buzz")
        else:
            print(i)
            
# This function adds two numbers
def add(x, y):
    return x + y

# This function subtracts two numbers
def subtract(x, y):
    return x - y

# This function multiplies two numbers
def multiply(x, y):
    return x * y

# This function divides two numbers
def divide(x, y):
    return x / y

def calcul():
	print("Select operation.")
	print("1.Add")
	print("2.Subtract")
	print("3.Multiply")
	print("4.Divide")

	while True:
	    # take input from the user
	    choice = input("Enter choice(1/2/3/4): ")

	    # check if choice is one of the four options
	    if choice in ('1', '2', '3', '4'):
		try:
		    num1 = float(input("Enter first number: "))
		    num2 = float(input("Enter second number: "))
		except ValueError:
		    print("Invalid input. Please enter a number.")
		    continue

		if choice == '1':
		    print(num1, "+", num2, "=", add(num1, num2))

		elif choice == '2':
		    print(num1, "-", num2, "=", subtract(num1, num2))

		elif choice == '3':
		    print(num1, "*", num2, "=", multiply(num1, num2))

		elif choice == '4':
		    print(num1, "/", num2, "=", divide(num1, num2))
		
		# check if user wants another calculation
		# break the while loop if answer is no
		next_calculation = input("Let's do next calculation? (yes/no): ")
		if next_calculation == "no":
		  break
	    else:
		print("Invalid Input")
