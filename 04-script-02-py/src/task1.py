a = 1
b = '2'
# c = a + b # <-- вот тут словим исключение

# для с == 12
c = str(a) + b  # для строки
print(c)

c = int(str(a) + b)  # для числа
print(c)

# для с == 3
c = a + int(b)  # для числа 3
print(c)
