package uteis;

import java.text.NumberFormat;
import java.util.Locale;

public class FormatUtils {

    private static final Locale BRASIL = new Locale("pt", "BR");
    private static final NumberFormat FORMATADOR_MOEDA = NumberFormat.getCurrencyInstance(BRASIL);

    /**
     * Formata um valor double como moeda no padrão brasileiro (R$ 1.234,56).
     * 
     * @param valor O valor numérico a ser formatado.
     * @return Uma string representando o valor formatado como moeda brasileira.
     */
    public static String formatarMoedaBR(double valor) {
        return FORMATADOR_MOEDA.format(valor);
    }
    
    /**
     * Formata um número de telefone (10 ou 11 dígitos) no padrão brasileiro.
     * Ex: (XX) XXXX-XXXX ou (XX) XXXXX-XXXX
     * Retorna o número original se a formatação não for aplicável.
     * 
     * @param telefone O número de telefone (apenas dígitos).
     * @return O telefone formatado ou o original se inválido.
     */
    public static String formatarTelefone(String telefone) {
        if (telefone == null) {
            return "";
        }
        // Remove qualquer caractere não numérico
        String numeros = telefone.replaceAll("[^0-9]", "");
        
        if (numeros.length() == 10) {
            // Formato (XX) XXXX-XXXX
            return String.format("(%s) %s-%s", 
                                 numeros.substring(0, 2),
                                 numeros.substring(2, 6),
                                 numeros.substring(6));
        } else if (numeros.length() == 11) {
            // Formato (XX) XXXXX-XXXX
            return String.format("(%s) %s-%s", 
                                 numeros.substring(0, 2),
                                 numeros.substring(2, 7),
                                 numeros.substring(7));
        } else {
            // Retorna o número original se não tiver 10 ou 11 dígitos
            return telefone; 
        }
    }

    /**
     * Formata um CPF (11 dígitos) no padrão brasileiro.
     * Ex: XXX.XXX.XXX-XX
     * Retorna o CPF original se a formatação não for aplicável.
     * 
     * @param cpf O CPF (apenas dígitos).
     * @return O CPF formatado ou o original se inválido.
     */
    public static String formatarCPF(String cpf) {
        if (cpf == null) {
            return "";
        }
        // Remove qualquer caractere não numérico
        String numeros = cpf.replaceAll("[^0-9]", "");
        
        if (numeros.length() == 11) {
            // Formato XXX.XXX.XXX-XX
            return String.format("%s.%s.%s-%s", 
                                 numeros.substring(0, 3),
                                 numeros.substring(3, 6),
                                 numeros.substring(6, 9),
                                 numeros.substring(9));
        } else {
            // Retorna o CPF original se não tiver 11 dígitos
            return cpf;
        }
    }
}

