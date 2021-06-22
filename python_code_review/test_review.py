class Test:
	def __init__(self, message):
		self.message = message

	def set_message(self, text):
		self.message = text


print("hello world")

computer = Test("Hello World")

print(computer.message)

computer.set_message("Leaving World")

print(computer.message)

