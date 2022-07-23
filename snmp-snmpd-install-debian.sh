#!/bin/bash
COMMUNITY=$1

#CHAMAR O SCRIPT USANDO sh script.sh nomedacommunity
#Instalar e configurar snmp numa máquina Linux UBUNTU E DEBIAN(RESPONDENDO IPV6 E IPV4) 
#Autor Franco Ferraciolli


#Configura o repositorio non-free para baixar as Mibs
touch /etc/apt/sources.list.d/nonfree.list
chmod 755 /etc/apt/sources.list.d/nonfree.list

cat <<EOF > /etc/apt/sources.list.d/nonfree.list
deb http://deb.debian.org/debian/ buster main contrib non-free
deb http://deb.debian.org/debian/ buster-updates main contrib non-free
deb http://security.debian.org/debian-security buster/updates main contrib non-free
EOF

#atualizar os diretórios apt
apt update -y 

#Instala o SNMP e SNMP agent 
apt install -y lsof snmp snmpd snmp-mibs-downloader snmptrapd libsnmp-base libsnmp-dev

#Faz backup e limpa o arquivo de configuração do snmpd 
cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.bkp
cat /dev/null > /etc/snmp/snmpd.conf

#Insere no arquivo snmpd.conf as informações necessárias (setar as informações conforme necessárias)
cat <<EOF > /etc/snmp/snmpd.conf
rocommunity $COMMUNITY
rocommunity6 $COMMUNITY
agentaddress udp:161
agentaddress udp6:161
syslocation  "INSIRA SUA LOCALIZAÇÂO"
syscontact  telic@test.com
rouser   authOnlyUser
sysServices    72
proc  mountd
proc  ntalkd    4
proc  sendmail 10 1
disk       /     10000
disk       /var  5%
includeAllDisks  10%
load   12 10 5
trapsink     localhost public
iquerySecName   internalUser
rouser          internalUser
defaultMonitors          yes
linkUpDownNotifications  yes
extend    test1   /bin/echo  Hello, world!
extend-sh test2   echo Hello, world! ; echo Hi there ; exit 35
master          agentx
EOF

#Restarta o serviço SNMP 
/etc/init.d/snmpd restart

#Realiza o teste final de conexão (com uma MIB que irá trazer informações de memoria, 12 Strings são esperadas
snmpwalk -v2c -c $COMMUNITY 127.0.0.1 1.3.6.1.2.1.25.2.3.1.3 

###Caso possua lsof instalado executar esses comandos para checar se a porta está escutando em v4 e v6
lsof -i4UDP:161
lsof -i6UDP:161