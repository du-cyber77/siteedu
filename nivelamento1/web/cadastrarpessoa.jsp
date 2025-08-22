<%@ include file="static/header.jsp" %>

<%@page import="control.PessoaDAO"%>
<%@page import="model.Pessoa"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<div class="container mt-4">
    <div class="row">
        <div class="col-md-8 offset-md-2">
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h3 class="panel-title">Cadastro de Pessoa</h3>
                </div>
                <div class="panel-body">
                    <%
                    try {
                        // Verificar se os parâmetros necessários foram enviados
                        String nome = request.getParameter("nome");
                        if (nome == null || nome.trim().isEmpty()) {
                            throw new Exception("O nome é obrigatório");
                        }
                        
                        // Usar o telefone sem formatação se disponível, caso contrário limpar o telefone recebido
                        String telefone = request.getParameter("telefone_sem_formatacao");
                        if (telefone == null || telefone.trim().isEmpty()) {
                            telefone = request.getParameter("telefone");
                            if (telefone == null || telefone.trim().isEmpty()) {
                                throw new Exception("O telefone é obrigatório");
                            }
                            telefone = telefone.replaceAll("\\D", "");
                        }
                        
                        // Usar o CPF sem formatação se disponível, caso contrário limpar o CPF recebido
                        String cpf = request.getParameter("cpf_sem_formatacao");
                        if (cpf == null || cpf.trim().isEmpty()) {
                            cpf = request.getParameter("cpf");
                            if (cpf == null || cpf.trim().isEmpty()) {
                                throw new Exception("O CPF é obrigatório");
                            }
                            cpf = cpf.replaceAll("\\D", "");
                        }
                        
                        // Verificar se o CPF tem 11 dígitos
                        if (cpf.length() != 11) {
                            throw new Exception("O CPF deve ter 11 dígitos");
                        }

                        String endereco = request.getParameter("endereco");
                        if (endereco == null || endereco.trim().isEmpty()) {
                            throw new Exception("O endereço é obrigatório");
                        }

                        // Converter para maiúsculas
                        nome = nome.toUpperCase();
                        endereco = endereco.toUpperCase();

                        // Criar objeto Pessoa
                        Pessoa pessoa = new Pessoa();
                        pessoa.setNome(nome);
                        pessoa.setTelefone(telefone);
                        pessoa.setCpf(cpf);
                        pessoa.setEndereco(endereco);

                        // Cadastrar no banco de dados
                        PessoaDAO pessoadao = new PessoaDAO();
                        boolean sucesso = pessoadao.cadastrarPessoa(pessoa);
                        
                        if (sucesso) {
                            %>
                            <div class="alert alert-success">
                                <i class="glyphicon glyphicon-ok-circle"></i> Pessoa cadastrada com sucesso!
                            </div>
                            <div class="text-center mt-4">
                                <a href="listartodaspessoas.jsp" class="btn btn-primary">
                                    <i class="glyphicon glyphicon-list"></i> Ver Lista de Pessoas
                                </a>
                                <a href="form_cadastrarpessoa.jsp" class="btn btn-success">
                                    <i class="glyphicon glyphicon-plus"></i> Cadastrar Nova Pessoa
                                </a>
                            </div>
                            <%
                        } else {
                            %>
                            <div class="alert alert-danger">
                                <i class="glyphicon glyphicon-exclamation-sign"></i> Erro ao cadastrar pessoa. 
                                Verifique se o CPF já está cadastrado ou se o banco de dados está acessível.
                            </div>
                            <div class="text-center mt-4">
                                <a href="form_cadastrarpessoa.jsp" class="btn btn-primary">
                                    <i class="glyphicon glyphicon-arrow-left"></i> Voltar e Tentar Novamente
                                </a>
                            </div>
                            <%
                        }
                    } catch (Exception e) {
                        %>
                        <div class="alert alert-danger">
                            <i class="glyphicon glyphicon-exclamation-sign"></i> Erro: <%= e.getMessage() %>
                        </div>
                        <div class="text-center mt-4">
                            <a href="form_cadastrarpessoa.jsp" class="btn btn-primary">
                                <i class="glyphicon glyphicon-arrow-left"></i> Voltar e Tentar Novamente
                            </a>
                        </div>
                        <%
                    }
                    %>
                </div>
            </div>
        </div>
    </div>
    
    <div class="row mt-4">
        <div class="col-md-8 offset-md-2 text-center">
            <a href="index.jsp" class="btn btn-default">
                <i class="glyphicon glyphicon-home"></i> Voltar para a página inicial
            </a>
        </div>
    </div>
</div>
