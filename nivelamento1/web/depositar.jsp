<%@page import="model.Pessoa"%>
<%@page import="control.PessoaDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ include file="static/header.jsp" %>

<center>
    <h1>Sistema de Controle Financeiro - Depósito</h1>

    
    <form action="processarDeposito.jsp" method="post" onsubmit="return prepararValor();">
        <!-- ID da pessoa (vindo da URL ou da lista) -->
        <input type="hidden" name="idPessoa" value="<%= request.getParameter("id") %>">

        <label for="moeda">Valor (R$):</label><br>
        <input type="text" id="moeda" name="valorFormatado" placeholder="R$ 0,00" oninput="formatarMoeda(this)" required />
        <input type="hidden" id="valorNumerico" name="valor" />
        
        <br><br>
        <label for="obs">Observação:</label><br>
        <input type="text" id="obs" name="obs" placeholder="Descrição do depósito" />
        
        <br><br>
        <input type="submit" value="Depositar">
    </form>

    <script>
        function formatarMoeda(input) {
            let valor = input.value.replace(/\D/g, '');
            if (valor.length > 2) {
                valor = valor.replace(/(\d{2})$/, ',$1');
            }
            if (valor.length > 5) {
                valor = valor.replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1.');
            }
            input.value = 'R$ ' + valor;
        }

        function prepararValor() {
            let valorFormatado = document.getElementById("moeda").value;
            let valorNumerico = valorFormatado.replace(/[^\d,]/g, '').replace(',', '.');
            document.getElementById("valorNumerico").value = valorNumerico;
            return true;
        }
    </script>
        
        <br><br>
       <a href="index.jsp" class="btn btn-default">
                    <i class="glyphicon glyphicon-home"></i> Voltar para a página inicial
                </a>
        
</center>
