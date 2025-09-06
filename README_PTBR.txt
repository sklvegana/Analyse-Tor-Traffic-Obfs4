
Analyse-Tor-Traffic-Obfs4

Visão Geral
------------
Analyse-Tor-Traffic-Obfs4.ps1 é um script PowerShell projetado para monitorar tráfego Tor e pontes (obfs4) no Windows.
Ele permite:
- Verificar se um IP pertence a um bloco de exit nodes Tor (/24).
- Listar conexões TCP de tor.exe e lyrebird.exe.
- Exportar IPs e portas remotas para um arquivo CSV.
- Monitorar conexões continuamente em tempo real (opcional).

O script cria automaticamente uma pasta:
%USERPROFILE%\toranalyse
onde todos os arquivos CSV são salvos.

Funcionalidades
---------------
1. Verificar Tor Exit Node
- Baixa a lista pública de exit nodes do Tor de https://check.torproject.org/torbulkexitlist.
- Compara os três primeiros octetos do IP com os blocos Tor.
- Exemplo de saída:

Verificando IP 51.222.13.177 (prefixo 51.222.13) na lista pública de exit nodes do Tor...
51.222.13.177 PERTENCE a um bloco de exit nodes Tor!

ou

51.222.13.177 NÃO pertence a nenhum bloco de exit nodes Tor.

2. Listar conexões Tor/Lyrebird
- Detecta processos tor.exe e lyrebird.exe em execução.
- Lista conexões TCP ativas:

Processos detectados: tor, lyrebird

LocalAddress  LocalPort  RemoteAddress   RemotePort  State
------------  ---------  -------------  ----------  -----
192.168.0.5   443        185.220.101.1  443        Established
192.168.0.5   9001       178.62.99.12   9001       Established

- Se nenhum processo estiver rodando:

Nenhum processo Tor ou Lyrebird ativo.

3. Exportar CSV
- Cria automaticamente:
C:\Users\<SeuUsuario>\toranalyse
- CSV salvo como tor_connections.csv com colunas:

RemoteAddress, RemotePort
185.220.101.1, 443
178.62.99.12, 9001

4. Monitoramento Contínuo (Opcional)
List-TorConnections -Continuous:$true
- Atualiza o console a cada 5 segundos.
- CSV é sobrescrito continuamente com as últimas conexões.
- Útil para monitoramento em tempo real do tráfego Tor.

Exemplos de Uso
---------------
# Verificar um IP específico e exportar conexões
.\Analyse-Tor-Traffic-Obfs4.ps1 -IpAddress "51.222.13.177"

# Monitoramento contínuo sem especificar CSV (usa pasta padrão)
List-TorConnections -Continuous:$true

# Verificar IP e exportar conexões continuamente
List-TorConnections -Continuous:$true

Parâmetros
----------
Parâmetro      Descrição
-IPAddress      Obrigatório. IP a ser verificado na lista de exit nodes Tor.
-Continuous     Opcional. Habilita monitoramento contínuo em tempo real.
-ExportPath     Opcional. Caminho completo para exportação do CSV. Padrão: %USERPROFILE%\toranalyse\tor_connections.csv.

Observações
-----------
- Monitora apenas conexões de tor.exe e lyrebird.exe.
- CSV contém apenas RemoteAddress e RemotePort.
- Monitoramento contínuo sobrescreve o CSV a cada atualização.
- Funciona melhor com PowerShell executado como Administrador.
