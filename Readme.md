# Página Inicial
id_ profssional e id_sujeito_de_teste são obrigatoriamente 4 digitos 

# Registro de Logs do Jogo "Tapa Certo"

Este documento descreve os dados extraídos e registrados no arquivo CSV durante a execução do jogo "Tapa Certo".

## Estrutura dos Logs

Os logs são armazenados em um arquivo CSV localizado no diretório de downloads do sistema. Cada linha do arquivo representa um evento registrado durante a sessão do jogo, contendo as seguintes informações:

### Campos do Log e Como São Obtidos:

1. **ID_Sessao**: Identificador único da sessão.
   - Gerado automaticamente pela função `gerar_id_único()`, que combina um número aleatório (`randi()`) com o tempo atual em milissegundos (`Time.get_ticks_msec()`).

2. **ID_Profissional**: Identificador do profissional responsável pela sessão.
   - Definido no início do jogo na função `iniciar_jogo()` com base no parâmetro `id_prof` fornecido.

3. **ID_Sujeito_De_Teste**: Identificador do jogador ou sujeito de teste.
   - Definido na função `iniciar_jogo()` com base no parâmetro `id_suj` fornecido.

4. **Data_Sessao**: Data e hora do início da sessão.
   - Obtido na inicialização do jogo pela função `obter_data_hora_atual()`, que chama `Time.get_datetime_string_from_system()` para capturar a data e hora atuais.

5. **Duracao_Sessao**: Tempo decorrido da sessão (em segundos).
   - Atualizado a cada frame na função `_process(delta)`, somando `delta` (tempo desde o último frame) à variável `duração_sessão`.

6. **Nome_Jogo**: Nome do jogo, neste caso "Tapa Certo".
   - Valor fixo atribuído na variável `nome_jogo`.

7. **Tempo_Resposta**: Tempo de resposta do jogador em segundos.
   - O tempo de resposta é calculado como a diferença entre o instante em que o alvo foi apresentado (`tempo_alvo_apresentado`) e o instante exato do clique do jogador (`Time.get_ticks_msec()`).
   - O valor obtido é inicialmente registrado em milissegundos e convertido para segundos dividindo por 1000.
   - Esse cálculo é realizado na função `registrar_tempo_resposta()`, que é chamada logo após a detecção do clique do jogador.

8. **Pontos**: Pontuação acumulada na sessão.
   - Atualizado na função `clique()`, somando 1 em caso de acerto e subtraindo 1 em caso de erro.

9. **Alvo_Atual**: Item ou alvo que o jogador precisa acertar.
   - Inicialmente definido na função `iniciar_jogo()`, escolhendo um alvo aleatório da enumeração `Alvos`.
   - Atualizado na função `clique()` quando o jogador acerta, garantindo que o novo alvo seja diferente do anterior.

10. **Acerto**: Indica se o jogador acertou (`true`) ou errou (`false`).
    - Registrado na função `clique()` conforme o alvo clicado pelo jogador.

11. **Suporte**: Indica se houve suporte adicional durante a jogabilidade.
    - Atualizado manualmente e registrado no log através da função `mudança_no_suporte()`.

## Armazenamento dos Logs

Os registros são armazenados no arquivo CSV utilizando a função `salvar_logs_csv()`. Se o arquivo não existir, ele é criado com o cabeçalho adequado. A cada nova entrada, os dados são escritos no final do arquivo. A pasta no Android em que ficará armazenado é a Download

## Encerramento da Sessão

Ao sair do jogo, a função `finalizar_sessão()` adiciona uma entrada especial ao log indicando o término da sessão, garantindo um registro completo da atividade do jogador. Para encerrar foi estilizado para que seja com 3 toques na telas de 4 dedos.



