import socket

# inicia captura de msgs
HOST = ''              # Endereco IP do Servidor
PORT = 5000            # Porta que o Servidor esta
udp = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
orig = (HOST, PORT)
udp.bind(orig)

# lista de clientes
clientes = []

def checaCliente(cl):
	print "checaCliente:::::: \n", cl
	#verifica se cliente ja esta na lista
	novoCliente = False

	if(len(clientes) > 0):
		for c in clientes:
			#print "- ", c, " / ", cl
			if(c != cl):
				#print "novo cliente"
				novoCliente = True
				break
	else:
		novoCliente = True

	if(novoCliente):
		print "Novo Cliente"
		clientes.append(cl)
	else:
		print "Cliente ja existe"
	print ":::::::::::::::::::"

def sendReply():
	print "Send Reply ::::::::::"
	for cl in clientes:
		print type(cl)
		print cl[0]
		udp.sendto("msg recebida", (cl[0], 6000) )
		

while True:
	msg, cliente = udp.recvfrom(1024)
	checaCliente(cliente)
	print cliente, msg
	#send reply
	sendReply()
	if (msg == "desconnect"):
		print "desligando servidor."
		exit()
		udp.close()
udp.close()
