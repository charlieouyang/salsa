import datetime
import pytz


class Account:

	@staticmethod
	#creates a static method, meaning u don't need the self parameter anymore and this static method can be called using Account._current_time
	def _current_time():
		utc_time = datetime.datetime.utcnow()
		return pytz.utc.localize(utc_time)

	def __init__(self, name, balance):
		self.name = name
		self.transaction_list = []
		self.balance = balance
		print("Account created for {} with balance of {}".format(self.name, self.balance))
		self.transaction_list.append((pytz.utc.localize(datetime.datetime.utcnow()), amount))

	def deposit(self, amount):
		if amount > 0:
			self.balance += amount
			self.show_balance()
			self.transaction_list.append((pytz.utc.localize(datetime.datetime.utcnow()), amount))

	def withdraw(self, amount):
		if 0 < amount <= self.balance:
			self.balance -= amount
			self.show_balance()
			self.transaction_list.append((pytz.utc.localize(datetime.datetime.utcnow()), -amount))
		else :
			print("cant do that my friend")

	def show_balance(self):
		print("Balance of: {}".format(self.balance))

	def show_transactions(self):
		for date, amount in self.transaction_list:
			if amount > 0:
				transaction_type = 'deposited'
			else :
				transaction_type = 'withdrawn'
				amount = amount * (-1)
			print("{:6} {} on {} (local time was {})".format(amount, transaction_type, date, date.astimezone()))


if __name__ == '__main__':
	kevin = Account("kevin", 0)
	kevin.show_balance()

	kevin.deposit(100)
	kevin.withdraw(50)
	kevin.show_balance()

	kevin.show_transactions()

	arya = Account("Arya", 5000)

	arya.deposit(500)
	arya.withdraw(4000)

	arya.show_transactions()
