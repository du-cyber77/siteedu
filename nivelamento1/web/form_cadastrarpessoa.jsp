<%@ include file="static/header.jsp" %>
<body class="bg-dark text-white">
    <h1 class="text-center mt-4 mb-4">Cadastrar Pessoa</h1>
    <div class="container bg-secondary p-4 rounded shadow" style="max-width: 600px;">
        <form action="cadastrarpessoa.jsp" method="post" class="needs-validation" novalidate autocomplete="on">
            <div class="mb-3">
                <label for="nome" class="form-label">Nome: <span style="color: #ff6666">*</span></label>
                <input type="text" class="form-control" id="nome" name="nome" required autofocus minlength="3" maxlength="60" aria-required="true" autocomplete="name">
                
            </div>
            <div class="mb-3">
                <label for="telefone" class="form-label">Telefone: <span style="color: #ff6666">*</span></label>
                <input type="tel" class="form-control" id="telefone" name="telefone" required maxlength="15" 
                       placeholder="(00) 00000-0000"
                       oninput="mascaraTelefone(this)" autocomplete="tel">
                <input type="hidden" id="telefone_sem_formatacao" name="telefone_sem_formatacao">
                
            </div>
            <div class="mb-3">
                <label for="cpf" class="form-label">CPF: <span style="color: #ff6666">*</span></label>
                <input type="text" class="form-control" id="cpf" name="cpf" required 
                       maxlength="14" 
                       placeholder="000.000.000-00"
                       pattern="\d{3}\.\d{3}\.\d{3}-\d{2}" 
                       title="O CPF deve estar no formato xxx.xxx.xxx-xx." 
                       autocomplete="off" 
                       oninput="mascaraCPF(this)">
                <input type="hidden" id="cpf_sem_formatacao" name="cpf_sem_formatacao">
                
            </div>
            <div class="mb-3">
                <label for="endereco" class="form-label">Endereço: <span style="color: #ff6666">*</span></label>
                <input type="text" class="form-control" id="endereco" name="endereco" required autocomplete="street-address">
               
            </div>
            <div class="d-flex justify-content-between mt-4"><br>
                <button type="submit" class="btn btn-success">Cadastrar</button>
                <button type="reset" class="btn btn-warning">Limpar</button>
                <a href="index.jsp" class="btn btn-outline-light">Voltar</a>
            </div>
        </form>
    </div>
    <script>
        // Máscaras 
        function mascaraTelefone(telefone) {
            let valor = telefone.value.replace(/\D/g, '');
            document.getElementById('telefone_sem_formatacao').value = valor;
            if (valor.length <= 10) {
                telefone.value = valor.replace(/^(\d{2})(\d)/g, '($1) $2').replace(/(\d{4})(\d)/, '$1-$2');
            } else {
                telefone.value = valor.replace(/^(\d{2})(\d)/g, '($1) $2').replace(/(\d{5})(\d)/, '$1-$2');
            }
        }
        function mascaraCPF(cpf) {
            let valor = cpf.value.replace(/\D/g, '');
            document.getElementById('cpf_sem_formatacao').value = valor;
            cpf.value = valor.replace(/(\d{3})(\d)/, '$1.$2').replace(/(\d{3})(\d)/, '$1.$2').replace(/(\d{3})(\d{1,2})$/, '$1-$2');
        }
        // Bootstrap validation
        (function () {
          'use strict';
          var forms = document.querySelectorAll('.needs-validation');
          Array.prototype.slice.call(forms)
            .forEach(function (form) {
              form.addEventListener('submit', function (event) {
                if (!form.checkValidity()) {
                  event.preventDefault();
                  event.stopPropagation();
                }
                form.classList.add('was-validated');
              }, false);
            });
        })();
    </script>
</body>
