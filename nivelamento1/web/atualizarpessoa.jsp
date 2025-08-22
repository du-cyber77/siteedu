<%@page import="model.Pessoa"%>
<%@page import="control.PessoaDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="static/header.jsp" %>


<%
    // Verificar se é uma submissão de formulário
    String metodo = request.getMethod();
    boolean atualizacaoRealizada = false;
    boolean sucesso = false;
    String mensagem = "";
    
    if ("POST".equalsIgnoreCase(metodo)) {
        try {
            // Recuperar os dados do formulário
            int id = Integer.parseInt(request.getParameter("id"));
            String nome = request.getParameter("nome");
            String telefone = request.getParameter("telefone");
            String cpf = request.getParameter("cpf");
            String endereco = request.getParameter("endereco");
            
            // Remover formatação do telefone e CPF
            telefone = telefone.replaceAll("[^0-9]", "");
            cpf = cpf.replaceAll("[^0-9]", "");
            
            // Criar objeto Pessoa
            Pessoa pessoa = new Pessoa();
            pessoa.setId(id);
            pessoa.setNome(nome);
            pessoa.setTelefone(telefone);
            pessoa.setCpf(cpf);
            pessoa.setEndereco(endereco);
            
            // Atualizar no banco de dados
            PessoaDAO dao = new PessoaDAO();
            dao.atualizarPessoa(pessoa);
            
            atualizacaoRealizada = true;
            sucesso = true;
            mensagem = "Dados atualizados com sucesso!";
        } catch (Exception e) {
            atualizacaoRealizada = true;
            sucesso = false;
            mensagem = "Erro ao atualizar dados: " + e.getMessage();
        }
    } else {
        // Se não for POST, recuperar o ID da URL e buscar a pessoa
        int id = Integer.parseInt(request.getParameter("id"));
        PessoaDAO dao = new PessoaDAO();
        Pessoa pessoa = dao.buscarPessoaPorId(id);
        
        // Armazenar no request para uso no formulário
        request.setAttribute("pessoa", pessoa);
    }
%>

<center>
    <h1>Sistema de Controle Financeiro - Atualizar Pessoa</h1>
    
    <% if (atualizacaoRealizada) { %>
        <div style="margin: 20px; padding: 10px; border-radius: 5px; 
                    background-color: <%= sucesso ? "#d4edda" : "#f8d7da" %>; 
                    color: <%= sucesso ? "#155724" : "#721c24" %>;">
            <%= mensagem %>
        </div>
        
        <% if (sucesso) { %>
            <div style="margin-top: 20px;">
                <a href="detalhespessoa.jsp?id=${pessoa.id}">Ver detalhes da pessoa</a> | 
                <a href="listartodaspessoas.jsp">Voltar para lista de pessoas</a>
            </div>
        <% } else { %>
            <div style="margin-top: 20px;">
                <a href="javascript:history.back()">Voltar e tentar novamente</a>
            </div>
        <% } %>
    <% } else { 
        // Recuperar a pessoa do request
        Pessoa pessoa = (Pessoa) request.getAttribute("pessoa");
        
        // Formatar CPF e telefone para exibição
        String cpfFormatado = pessoa.getCpf();
        String telefoneFormatado = pessoa.getTelefone();
        
        // Remover formatação existente
        cpfFormatado = cpfFormatado.replaceAll("[^0-9]", "");
        telefoneFormatado = telefoneFormatado.replaceAll("[^0-9]", "");
        
        // Aplicar formatação
        if (cpfFormatado.length() == 11) {
            cpfFormatado = cpfFormatado.substring(0, 3) + "." + 
                          cpfFormatado.substring(3, 6) + "." + 
                          cpfFormatado.substring(6, 9) + "-" + 
                          cpfFormatado.substring(9);
        }
        
        if (telefoneFormatado.length() >= 10) {
            telefoneFormatado = "(" + telefoneFormatado.substring(0, 2) + ") " + 
                               telefoneFormatado.substring(2, 7) + "-" + 
                               telefoneFormatado.substring(7);
        }
    %>
    
    <form action="atualizarpessoa.jsp" method="post" onsubmit="return validarFormulario()">
        <input type="hidden" name="id" value="<%= pessoa.getId() %>">
        
        <table style="width: 50%; margin-top: 20px;">
            <tr>
                <td style="text-align: right; padding: 8px;"><label for="nome">Nome:</label></td>
                <td><input type="text" id="nome" name="nome" value="<%= pessoa.getNome() %>" style="width: 100%; padding: 8px;" required></td>
            </tr>
            <tr>
                <td style="text-align: right; padding: 8px;"><label for="telefone">Telefone:</label></td>
                <td><input type="text" id="telefone" name="telefone" value="<%= telefoneFormatado %>" style="width: 100%; padding: 8px;" required></td>
            </tr>
            <tr>
                <td style="text-align: right; padding: 8px;"><label for="cpf">CPF:</label></td>
                <td><input type="text" id="cpf" name="cpf" value="<%= cpfFormatado %>" style="width: 100%; padding: 8px;" required></td>
            </tr>
            <tr>
                <td style="text-align: right; padding: 8px;"><label for="endereco">Endereço:</label></td>
                <td><input type="text" id="endereco" name="endereco" value="<%= pessoa.getEndereco() %>" style="width: 100%; padding: 8px;" required></td>
            </tr>
            <tr>
                <td colspan="2" style="text-align: center; padding-top: 20px;">
                    <input type="submit" value="Atualizar" style="padding: 10px 20px; background-color: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer;">
                    <a href="listartodaspessoas.jsp" style="margin-left: 10px; padding: 10px 20px; background-color: #6c757d; color: white; text-decoration: none; border-radius: 4px;">Cancelar</a>
                </td>
            </tr>
        </table>
    </form>
    
    <script>
        function validarFormulario() {
            var nome = document.getElementById("nome").value;
            var telefone = document.getElementById("telefone").value;
            var cpf = document.getElementById("cpf").value;
            var endereco = document.getElementById("endereco").value;
            
            if (nome.trim() === "") {
                alert("Por favor, preencha o nome.");
                return false;
            }
            
            if (telefone.trim() === "") {
                alert("Por favor, preencha o telefone.");
                return false;
            }
            
            if (cpf.trim() === "") {
                alert("Por favor, preencha o CPF.");
                return false;
            }
            
            if (endereco.trim() === "") {
                alert("Por favor, preencha o endereço.");
                return false;
            }
            
            // Formatar telefone e CPF antes de enviar
            document.getElementById("telefone").value = telefone.replace(/\D/g, "");
            document.getElementById("cpf").value = cpf.replace(/\D/g, "");
            
            return true;
        }
        
        // Adicionar máscaras de formatação
        document.getElementById("telefone").addEventListener("input", function(e) {
            var value = e.target.value.replace(/\D/g, "");
            if (value.length > 0) {
                value = "(" + value.substring(0, 2) + ") " + value.substring(2, 7) + (value.length > 7 ? "-" + value.substring(7, 11) : "");
            }
            e.target.value = value;
        });
        
        document.getElementById("cpf").addEventListener("input", function(e) {
            var value = e.target.value.replace(/\D/g, "");
            if (value.length > 0) {
                value = value.substring(0, 3) + (value.length > 3 ? "." + value.substring(3, 6) : "") + 
                       (value.length > 6 ? "." + value.substring(6, 9) : "") + 
                       (value.length > 9 ? "-" + value.substring(9, 11) : "");
            }
            e.target.value = value;
        });
    </script>
    <% } %>
</center>





