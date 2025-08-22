<%-- 
    Document   : pesquisarpessoaavancado
    Created on : 26 de mai. de 2025, 19:39:55
    Author     : Eduardo Almeida
--%>

<%@page import="uteis.FormatUtils"%>
<%@page import="control.PessoaDAO"%>
<%@page import="model.Pessoa"%>
<%@page import="java.util.ArrayList"%>
<%@page import="control.MovimentacaoDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="static/header.jsp" %>

<%
    // Carregar todas as pessoas para filtragem dinâmica via JavaScript
    PessoaDAO pessoaDAO = new PessoaDAO();
    ArrayList<Pessoa> todasPessoas = pessoaDAO.listaPessoas();
%>

<div class="container mt-4">
    <div class="row">
        <div class="col-md-12">
            <h1 class="text-center mt-4 mb-4">Pesquisa Avançada de Pessoas</h1>
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h3 class="panel-title"><i class="glyphicon glyphicon-search"></i> Pesquisa Dinâmica</h3>
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="form-group">
                                <label for="pesquisaDinamica">Pesquisar por Nome ou ID:</label>
                                <div class="input-group" style="position: relative;">
                                    <span class="input-group-addon"><i class="glyphicon glyphicon-search"></i></span>
                                    <input type="text" class="form-control" id="pesquisaDinamica" 
                                           placeholder="Digite para ver sugestões..." 
                                           autocomplete="off"
                                           autofocus>
                                    <div id="sugestoesPesquisa" class="sugestoes-dropdown"></div>
                                </div>
                                
                                <small class="text-muted">Digite pelo menos 3 letras para ver sugestões de pessoas cadastradas.</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
   

<style>
    /* Estilo para o dropdown de sugestões */
    .sugestoes-dropdown {
        position: absolute;
        width: 100%;
        max-height: 250px;
        overflow-y: auto;
        background-color: white;
        border: 1px solid #ccc;
        border-top: none;
        border-radius: 0 0 4px 4px;
        box-shadow: 0 6px 12px rgba(0,0,0,.175);
        z-index: 9999; /* Aumentado para garantir que fique sobre outros elementos */
        display: none;
        top: 100%;
        left: 0;
    }
    
    .sugestao-item {
        padding: 8px 15px;
        cursor: pointer;
        border-bottom: 1px solid #f0f0f0;
    }
    
    .sugestao-item:hover, .sugestao-item.active {
        background-color: #f5f5f5;
    }
    
    .sugestao-item .id {
        color: #777;
        margin-right: 5px;
        font-weight: bold;
    }
    
    .sugestao-item .nome {
        font-weight: normal;
    }
    
    .highlight {
        background-color: #ffffd0;
        font-weight: bold;
    }
    
    .form-group {
        position: relative;
    }
</style>

<script>
    // Garantir que o jQuery esteja carregado antes de executar o código
    $(document).ready(function() {
        // Array para armazenar os dados de pessoas para sugestões
        var pessoasData = [
            <% for (Pessoa pessoa : todasPessoas) { %>
                { 
                    id: <%= pessoa.getId() %>, 
                    nome: "<%= pessoa.getNome().replace("\"", "\\\"") %>", 
                    cpf: "<%= pessoa.getCpf() %>" 
                }<%= todasPessoas.indexOf(pessoa) < todasPessoas.size() - 1 ? "," : "" %>
            <% } %>
        ];
        
        // Elementos DOM
        var inputPesquisa = document.getElementById('pesquisaDinamica');
        var sugestoesPesquisa = document.getElementById('sugestoesPesquisa');
        
        // Variáveis para controle de navegação nas sugestões
        var sugestaoAtiva = -1;
        var sugestoesFiltradas = [];
        
        // Função para mostrar sugestões baseadas no texto digitado
        function mostrarSugestoes(texto) {
            // Limpar sugestões anteriores
            sugestoesPesquisa.innerHTML = '';
            sugestaoAtiva = -1;
            
            // Não mostrar sugestões se o texto tiver menos de 3 caracteres
            if (texto.length < 3) {
                sugestoesPesquisa.style.display = 'none';
                return;
            }
            
            // Filtrar pessoas que correspondem ao texto digitado
            sugestoesFiltradas = pessoasData.filter(function(pessoa) {
                return pessoa.nome.toLowerCase().includes(texto.toLowerCase()) || 
                       pessoa.id.toString().includes(texto);
            });
            
            // Mostrar até 10 sugestões
            var maxSugestoes = Math.min(50, sugestoesFiltradas.length); // Aumentado de 10 para 50
            
            if (maxSugestoes === 0) {
                sugestoesPesquisa.style.display = 'none';
                return;
            }
            
            // Criar elementos de sugestão
            for (var i = 0; i < maxSugestoes; i++) {
                var pessoa = sugestoesFiltradas[i];
                var sugestaoItem = document.createElement('div');
                sugestaoItem.className = 'sugestao-item';
                
                // Destacar o texto correspondente na sugestão
                var nomeHtml = pessoa.nome;
                if (texto.length > 0) {
                    var regex = new RegExp('(' + texto + ')', 'gi');
                    nomeHtml = pessoa.nome.replace(regex, '<span class="highlight">$1</span>');
                }
                
                sugestaoItem.innerHTML = '<span class="id">#' + pessoa.id + '</span> <span class="nome">' + nomeHtml + '</span> <small class="text-muted">' + pessoa.cpf + '</small>';
                
                // Adicionar evento de clique usando closure para preservar a referência à pessoa
                (function(pessoaAtual) {
                    sugestaoItem.addEventListener('click', function() {
                        inputPesquisa.value = pessoaAtual.nome;
                        sugestoesPesquisa.style.display = 'none';
                        
                        // Redirecionar para a página de detalhes da pessoa
                        window.location.href = 'detalhespessoa.jsp?id=' + pessoaAtual.id;
                    });
                })(pessoa);
                
                sugestoesPesquisa.appendChild(sugestaoItem);
            }
            
            // Mostrar o dropdown de sugestões
            sugestoesPesquisa.style.display = 'block';
            
            // Verificar se há dados no console para debug
            console.log("Termo pesquisado: " + texto);
            console.log("Sugestões encontradas: " + sugestoesFiltradas.length);
        }
        
        // Função para navegar pelas sugestões com teclado
        function navegarSugestoes(direcao) {
            var sugestoes = sugestoesPesquisa.querySelectorAll('.sugestao-item');
            
            // Remover classe ativa da sugestão atual
            if (sugestaoAtiva >= 0 && sugestaoAtiva < sugestoes.length) {
                sugestoes[sugestaoAtiva].classList.remove('active');
            }
            
            // Atualizar índice da sugestão ativa
            sugestaoAtiva += direcao;
            
            // Verificar limites
            if (sugestaoAtiva < 0) {
                sugestaoAtiva = sugestoes.length - 1;
            } else if (sugestaoAtiva >= sugestoes.length) {
                sugestaoAtiva = 0;
            }
            
            // Adicionar classe ativa à nova sugestão
            if (sugestaoAtiva >= 0 && sugestaoAtiva < sugestoes.length) {
                sugestoes[sugestaoAtiva].classList.add('active');
                // Garantir que a sugestão ativa esteja visível no scroll
                sugestoes[sugestaoAtiva].scrollIntoView({ block: 'nearest' });
            }
        }
        
        // Função para selecionar a sugestão ativa
        function selecionarSugestaoAtiva() {
            var sugestoes = sugestoesPesquisa.querySelectorAll('.sugestao-item');
            
            if (sugestaoAtiva >= 0 && sugestaoAtiva < sugestoes.length) {
                // Simular clique na sugestão ativa
                sugestoes[sugestaoAtiva].click();
            }
        }
        
        // Evento de input para mostrar sugestões
        inputPesquisa.addEventListener('input', function() {
            var termoPesquisa = this.value.trim();
            mostrarSugestoes(termoPesquisa);
        });
        
        // Eventos de teclado para navegação nas sugestões
        inputPesquisa.addEventListener('keydown', function(e) {
            // Se o dropdown de sugestões estiver visível
            if (sugestoesPesquisa.style.display === 'block') {
                switch (e.key) {
                    case 'ArrowDown':
                        e.preventDefault();
                        navegarSugestoes(1);
                        break;
                    case 'ArrowUp':
                        e.preventDefault();
                        navegarSugestoes(-1);
                        break;
                    case 'Enter':
                        e.preventDefault();
                        selecionarSugestaoAtiva();
                        break;
                    case 'Escape':
                        sugestoesPesquisa.style.display = 'none';
                        break;
                }
            }
        });
        
        // Fechar sugestões ao clicar fora
        $(document).on('click', function(e) {
            if (!$(inputPesquisa).is(e.target) && !$(sugestoesPesquisa).is(e.target) && $(sugestoesPesquisa).has(e.target).length === 0) {
                sugestoesPesquisa.style.display = 'none';
            }
        });
        
        // Inicializar tooltips
        $('[data-toggle="tooltip"]').tooltip();
        
        // Teste inicial para verificar se o script está sendo executado
        console.log("Script de autocomplete inicializado");
        console.log("Total de pessoas carregadas: " + pessoasData.length);
    });
</script>
