; Aluno: JoÃ£o Marcelo Candido Borges]
; Matri­cula: 20190112971

.686
.model flat, stdcall
option casemap:none

include \masm32\include\kernel32.inc
include \masm32\include\msvcrt.inc
include \masm32\include\windows.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\msvcrt.lib
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib

.data

nome_arquivo db 50 dup(0)  ;nome do arquivo de entrada
saida_arquivo db 30 dup(0) ;nome do arquivo de saida
aux_string db 50 dup(0)    ;string aux para ajudar a tratar caracteres especiais
fileBuffer db 54 dup(0)    ;array de bytes que serÃ£o gravados no arquivo
pixels db 3 dup(0)         ;array de bytes que representam os pixels

mensagem_1 db "Digite o nome do arquivo de entrada:",0
mensagem_2 db "Digite o nome do arquivo de saida:" ,0
mensagem_3 db "Digite o codigo (0 - azul/ 1 - verde/ 2 - vermelho):" ,0
mensagem_4 db "Digite o valor da intensidade: " ,0

cor dd 0          ;valor para representar a cor a ser alterada
valor dd 0        ;valor a ser incrementado no pixel selecionado
fileHandle dd 0   ;handle para o arquivo de entrada
fileHandle_2 dd 0 ;handle para o arquivo 
cont_leitura dd 0 ;guarda o valor dos bytes lidos do arquivo
cont_escrita dd 0 ;guarda o valor dos bytes escritos no arquivo


inputHandle dd 0 ; Variavel para armazenar o handle de entrada
outputHandle dd 0 ; Variavel para armazenar o handle de saida
console_count dd 0 ; Variavel para armazenar caracteres lidos/escritos na console
tamanho_string dd 0 ; Variavel para armazenar tamanho de string terminada em 0

.code

start:

invoke GetStdHandle, STD_OUTPUT_HANDLE
mov outputHandle, eax

invoke GetStdHandle, STD_INPUT_HANDLE
mov inputHandle, eax


invoke WriteConsole, outputHandle, addr mensagem_1, sizeof mensagem_1 , addr console_count, NULL ;printa mensagem_1

invoke ReadConsole, inputHandle, addr nome_arquivo, sizeof nome_arquivo, addr console_count,NULL ;ler o nome do arquivo de entrada

invoke WriteConsole, outputHandle, addr mensagem_2, sizeof mensagem_2 , addr console_count, NULL ;printa mensagem_2

invoke ReadConsole, inputHandle, addr saida_arquivo, sizeof nome_arquivo, addr console_count,NULL ;ler o nome do arquivo de saida

invoke WriteConsole, outputHandle, addr mensagem_3, sizeof mensagem_3 , addr console_count, NULL


invoke ReadConsole, inputHandle, addr aux_string, sizeof aux_string , addr console_count,NULL

push offset aux_string
call remove_cl_lf

invoke atodw, addr aux_string

mov cor, eax

invoke WriteConsole, outputHandle, addr mensagem_4, sizeof mensagem_4 , addr console_count, NULL; printa mensagem_4

invoke ReadConsole, inputHandle, addr aux_string, sizeof aux_string , addr console_count,NULL; ler a string auxiliar representado um valor

push offset aux_string
call remove_cl_lf ;chama a funcao que trata os caracteres especiais 

invoke atodw, addr aux_string ;converte a string aux para inteiro

mov valor, eax ;o valor Ã© retornado em eax e movido para sua variavel correta

push offset nome_arquivo
call remove_cl_lf

invoke CreateFile, addr nome_arquivo, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL

mov fileHandle, eax

invoke ReadFile, fileHandle, addr fileBuffer,  sizeof fileBuffer, addr cont_leitura,NULL

push offset saida_arquivo
call remove_cl_lf

invoke CreateFile, addr saida_arquivo, GENERIC_WRITE, 0, NULL,
CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL

mov fileHandle_2, eax

invoke WriteFile, fileHandle_2, addr fileBuffer, sizeof fileBuffer, addr cont_escrita,NULL ; Escreve 54 bytes (cabecalho) do arquivo

looop: ;label que permite ler ate o fim do arquivo

       invoke ReadFile, fileHandle, addr pixels, 3 , addr cont_leitura, NULL ;  ler 3 bytes do arquivo
       cmp cont_leitura, 0
       je fim
       push offset pixels
       push cor
       push valor
       call substitui_byte

       invoke WriteFile, fileHandle_2, addr pixels, 3 , addr cont_escrita, NULL
       
       jmp looop
       
       
fim: ;label que fecha o arquivo de entrada e o de saida, encerrando o programa

     invoke CloseHandle, fileHandle
     invoke CloseHandle, fileHandle_2
     invoke ExitProcess, 0

remove_cl_lf: ; Funcao para remover os caracteres Carriage Return e Line Feed da string recebida como parametro
        push ebp
        mov ebp, esp

        mov esi, DWORD PTR [ebp+8] 
    
        proximo:
        mov al, [esi]
        inc esi 
        cmp al, 13
        jne proximo
        dec esi
        xor al, al
        mov [esi], al

        mov esp, ebp
        pop ebp
        ret 4

substitui_byte: ; funcao que subsititui o byte do array de bytes, incrementado uma intensidade ao valor original
      
        push ebp
        mov ebp, esp
        sub esp, 12
        
        mov eax,  DWORD PTR[ebp + 16]
        mov ecx,  DWORD PTR[ebp + 12]
        mov edx,  DWORD PTR[ebp + 8]   
        
        mov DWORD PTR[ebp - 4], edx
        mov DWORD PTR[ebp - 8], ecx
        mov DWORD PTR[ebp - 12], eax 

        mov ebx, 0
        mov bl, BYTE PTR[eax + ecx]


        add edx, ebx
        cmp edx, 255
        jle continua
        mov dl, 255

        continua:            
        mov BYTE PTR[eax + ecx], dl
                
        mov esp, ebp
        pop ebp
        ret 12


end start
