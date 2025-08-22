<%@page import="java.util.ArrayList"%>
<%@page import="model.Movimentacao"%>
<%@page import="control.PessoaDAO, control.MovimentacaoDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="static/header.jsp" %>

<%
    // Verificar se é uma confirmação
    String confirmacao = request.getParameter("confirmar");
    boolean operacaoRealizada = false;
    boolean sucesso = false;
    String mensagem = "";
    int idPessoa = 0;
    
    try {
        idPessoa = Integer.parseInt(request.getParameter("id"));
        
        if ("sim".equals(confirmacao)) {
            operacaoRealizada = true;
            
            // Excluir a pessoa e todas as suas movimentações usando o método correto
            PessoaDAO pessoaDAO = new PessoaDAO();
            sucesso = pessoaDAO.excluirPessoaEHistorico(idPessoa);
            
            if (sucesso) {
                mensagem = "Pessoa e todas as suas movimentações foram excluídas com sucesso!";
            } else {
                mensagem = "Erro ao excluir a pessoa. Por favor, tente novamente.";
            }
        }
    } catch (Exception e) {
        operacaoRealizada = true;
        sucesso = false;
        mensagem = "Erro ao processar a exclusão: " + e.getMessage();
    }
%>

<div class="container">
    <div class="row">
        <div class="col-md-12">
            <div class="panel panel-danger">
                <div class="panel-heading">
                    <h3 class="panel-title"><i class="glyphicon glyphicon-trash"></i> Excluir Pessoa</h3>
                </div>
                <div class="panel-body">
                    <% if (!operacaoRealizada) { %>
                        <div class="alert alert-danger">
                            <h4><i class="glyphicon glyphicon-warning-sign"></i> ATENÇÃO: Esta operação irá excluir a pessoa e todas as suas movimentações!</h4>
                            <p>Esta ação não pode ser desfeita. Todos os registros serão permanentemente removidos do sistema.</p>
                            
                            <form action="excluirpessoa.jsp" method="post" style="margin-top: 20px;">
                                <input type="hidden" name="id" value="<%= idPessoa %>">
                                <input type="hidden" name="confirmar" value="sim">
                                <div class="text-center">
                                    <button type="submit" class="btn btn-danger">
                                        <i class="glyphicon glyphicon-trash"></i> Confirmar Exclusão
                                    </button>
                                    <a href="detalhespessoa.jsp?id=<%= idPessoa %>" class="btn btn-default">
                                        <i class="glyphicon glyphicon-remove"></i> Cancelar
                                    </a>
                                </div>
                            </form>
                        </div>
                    <% } else { %>
                        <div class="alert <%= sucesso ? "alert-success" : "alert-danger" %>">
                            <h4><i class="glyphicon <%= sucesso ? "glyphicon-ok-circle" : "glyphicon-remove-circle" %>"></i> 
                                <%= sucesso ? "Exclusão realizada com sucesso!" : "Erro na exclusão" %>
                            </h4>
                            <p><%= mensagem %></p>
                        </div>
                        
                        <div class="text-center" style="margin-top: 20px;">
                            <% if (sucesso) { %>
                                <a href="listartodaspessoas.jsp" class="btn btn-primary">
                                    <i class="glyphicon glyphicon-list"></i> Voltar para Lista de Pessoas
                                </a>
                            <% } else { %>
                                <a href="detalhespessoa.jsp?id=<%= idPessoa %>" class="btn btn-primary">
                                    <i class="glyphicon glyphicon-user"></i> Voltar para Detalhes da Pessoa
                                </a>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>
