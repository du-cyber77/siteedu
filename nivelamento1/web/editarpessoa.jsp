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
    Pessoa pessoa = null;
    
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
            pessoa = new Pessoa();
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
        pessoa = dao.buscarPessoaPorId(id);
    }
    
    // Formatar CPF e telefone para exibição
    String cpfFormatado = "";
    String telefoneFormatado = "";
    
    if (pessoa != null) {
        cpfFormatado = pessoa.getCpf();
        telefoneFormatado = pessoa.getTelefone();
        
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
    }
%>

<center><h1>Editar Pessoa</h1></center>

<% if (atualizacaoRealizada) { %>
    <div class="alert <%= sucesso ? "alert-success" : "alert-danger" %>">
        <%= mensagem %>
    </div>
    
    <div class="mt-3">
        <% if (sucesso) { %>
            <a href="detalhespessoa.jsp?id=<%= pessoa.getId() %>" class="btn btn-primary">Ver detalhes da pessoa</a>
            <a href="listartodaspessoas.jsp" class="btn btn-secondary">Voltar para lista de pessoas</a>
        <% } else { %>
            <a href="javascript:history.back()" class="btn btn-primary">Voltar e tentar novamente</a>
        <% } %>
    </div>
<% } else if (pessoa != null) { %>
    <div style="display: flex; justify-content: center;">
        <form action="editarpessoa.jsp" method="post" onsubmit="return validarFormulario()" class="card" style="width: 80%; max-width: 600px;">
            <div class="card-header">
                <h2>Dados Pessoais</h2>
            </div>
            <div class="card-body">
                <input type="hidden" name="id" value="<%= pessoa.getId() %>">
                
                <div class="form-group">
                    <label for="nome">Nome:</label>
                    <input type="text" id="nome" name="nome" value="<%= pessoa.getNome() %>" class="form-control" required>
                </div>
                
                <div class="form-group">
                    <label for="telefone">Telefone:</label>
                    <input type="text" id="telefone" name="telefone" value="<%= telefoneFormatado %>" class="form-control" required>
                </div>
                
                <div class="form-group">
                    <label for="cpf">CPF:</label>
                    <input type="text" id="cpf" name="cpf" value="<%= cpfFormatado %>" class="form-control" required>
                </div>
                
                <div class="form-group">
                    <label for="endereco">Endereço:</label>
                    <input type="text" id="endereco" name="endereco" value="<%= pessoa.getEndereco() %>" class="form-control" required>
                </div>
                
                <div class="text-center mt-3">
                    <button type="submit" class="btn btn-success">Atualizar</button>
                    <a href="detalhespessoa.jsp?id=<%= pessoa.getId() %>" class="btn btn-secondary">Cancelar</a>
                </div>
            </div>
        </form>
    </div>
    
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
                value = "(" + value.substring(0, 2) + ")" + (value.length > 2 ? " " + value.substring(2, 7) : "") + 
                       (value.length > 7 ? "-" + value.substring(7, 11) : "");
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
<% } else { %>
    <div class="alert alert-danger">
        Pessoa não encontrada.
    </div>
    <a href="listartodaspessoas.jsp" class="btn btn-primary">Voltar para lista de pessoas</a>
<% } %>


