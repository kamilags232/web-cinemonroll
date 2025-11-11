package apresentacao;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.math.BigDecimal;

import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFormattedTextField;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JTextField;
import javax.swing.text.MaskFormatter;

import negocio.Ingresso;
import negocio.Pessoa;
import negocio.Venda;
import persistencia.FilmeDAO;
import persistencia.IngressoDAO;
import persistencia.PessoaDAO;
import persistencia.VendaLancheDAO;

public class VisaoPessoa extends JFrame {

    private static final long serialVersionUID = 1L;

    // Cliente
    private JLabel lblNome = new JLabel("Nome");
    private JTextField txtNome = new JTextField();

    private JLabel lblEmail = new JLabel("Email");
    private JTextField txtEmail = new JTextField();

    private JLabel lblCpf = new JLabel("CPF");
    private JFormattedTextField txtCpf;

    // Filme / Assento
    private JLabel lblFilme = new JLabel("Filme");
    private JComboBox<String> cbFilme;

    private JLabel lblAssento = new JLabel("Assento");
    private JTextField txtAssento = new JTextField();
    
    private JLabel lblLanche = new JLabel("Lanche");
    private JComboBox<String> cbLanche;

    private JLabel lblQtd = new JLabel("Qtd");
    private JComboBox<Integer> cbQtd;

    private JLabel lblPagamento = new JLabel("Pagamento");
    private JComboBox<String> cbPagamento;


    private JButton btnConfirmar = new JButton("Confirmar");

    public static void main(String[] args) {
        new VisaoPessoa().setVisible(true);
    }

    public VisaoPessoa() {
        setTitle("Venda de Ingresso - Cinema");
        setSize(420, 410);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        setLayout(null);

        try {
            MaskFormatter cpfMask = new MaskFormatter("###.###.###-##");
            cpfMask.setPlaceholderCharacter('_');
            txtCpf = new JFormattedTextField(cpfMask);
        } catch (Exception e) {
            e.printStackTrace();
            txtCpf = new JFormattedTextField(); // fallback
        }

        // criar/popular combo de filmes (no construtor)
        String[] filmes = {
        	    "Vingadores: Ultimato",
        	    "The Batman",
        	    "Oppenheimer",
        	    "Avatar: O Caminho da Água",
        	    "Coringa",
        	    "Homem-Aranha: Sem Volta Para Casa",
        	    "Frozen 2",
        	    "Barbie"
        	};

        };
        cbFilme = new JComboBox<>(filmes);
        
     // lanches
        String[] lanches = {
            "Nenhum",
            "Combo pipoca + refri",
            "Pipoca média",
            "Refrigerante",
            "Doce"
        };
        cbLanche = new JComboBox<>(lanches);
        cbLanche.setBounds(10, 260, 200, 20);
        add(cbLanche);

        // quantidade
        Integer[] qtd = {1,2,3,4,5};
        cbQtd = new JComboBox<>(qtd);
        cbQtd.setBounds(220, 260, 50, 20);
        add(cbQtd);

        // método de pagamento
        String[] metodos = {"Pix", "Cartão de crédito", "Boleto bancário"};
        cbPagamento = new JComboBox<>(metodos);
        cbPagamento.setBounds(10, 290, 200, 20);
        add(cbPagamento);


        // layout componentes
        lblNome.setBounds(10, 10, 200, 20);
        add(lblNome);
        txtNome.setBounds(10, 30, 380, 20);
        add(txtNome);

        lblEmail.setBounds(10, 60, 200, 20);
        add(lblEmail);
        txtEmail.setBounds(10, 80, 380, 20);
        add(txtEmail);

        lblCpf.setBounds(10, 110, 200, 20);
        add(lblCpf);
        txtCpf.setBounds(10, 130, 160, 20);
        add(txtCpf);

        lblFilme.setBounds(10, 160, 200, 20);
        add(lblFilme);
        cbFilme.setBounds(10, 180, 380, 20);
        add(cbFilme);

        lblAssento.setBounds(10, 210, 200, 20);
        add(lblAssento);
        txtAssento.setBounds(10, 230, 160, 20);
        add(txtAssento);

        btnConfirmar.setBounds(140, 325, 120, 30);
        add(btnConfirmar);

        // ação do botão: 1) cliente 2) venda 3) ingresso
        btnConfirmar.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                try {
                    // validações simples
                    String nome = txtNome.getText().trim();
                    String email = txtEmail.getText().trim();
                    String cpf = txtCpf.getText().trim();
                    String assento = txtAssento.getText().trim();
                    String filmeEscolhido = (String) cbFilme.getSelectedItem();
                    BigDecimal total = new BigDecimal("20.00");
                    String lancheEscolhido = (String) cbLanche.getSelectedItem();
                    int quantidade = (int) cbQtd.getSelectedItem();
                    String pagamento = (String) cbPagamento.getSelectedItem();
                    JOptionPane.showMessageDialog(null,
                        "Compra concluída!");


                    if (!lancheEscolhido.equals("Nenhum")) {

                        switch (lancheEscolhido) {
                            case "Combo pipoca + refri": total = total.add(new BigDecimal("35.00").multiply(new BigDecimal(quantidade))); break;
                            case "Pipoca média":         total = total.add(new BigDecimal("20.00").multiply(new BigDecimal(quantidade))); break;
                            case "Refrigerante":         total = total.add(new BigDecimal("12.00").multiply(new BigDecimal(quantidade))); break;
                            case "Doce":                 total = total.add(new BigDecimal("10.00").multiply(new BigDecimal(quantidade))); break;
                        }
                    }


                    if (nome.isEmpty()) {
                        JOptionPane.showMessageDialog(null, "Preencha o nome.");
                        return;
                    }
                    if (email.isEmpty()) {
                        JOptionPane.showMessageDialog(null, "Preencha o email.");
                        return;
                    }
                    if (cpf.contains("_")) {
                        cpf = null;
                    }

                    if (assento.isEmpty()) {
                        JOptionPane.showMessageDialog(null, "Preencha o assento (ex: A5).");
                        return;
                    }

                    // 1) gravar cliente e obter cd_cliente
                    Pessoa p = new Pessoa();
                    p.setCliente(nome);
                    p.setEmail(email);
                    p.setCpf(cpf);
                    int cdCliente = new PessoaDAO().persistir(p);

                    // 2) descobrir cd_filme e cd_sessao automaticamente
                    int cdFilme = FilmeDAO.getCodigoDoFilme(filmeEscolhido);
                    int cdSessao = FilmeDAO.getSessaoPorFilme(cdFilme);
                    
                 // impedir assento repetido
                    if (IngressoDAO.assentoOcupado(assento, cdSessao)) {
                        JOptionPane.showMessageDialog(null, "Este assento já foi vendido!");
                        return;
                    }
                    
                    if (!assento.matches("[A-Z]\\d{1,2}")) {
                        JOptionPane.showMessageDialog(null, "Assento inválido! Ex: A5");
                        return;
                    }

                    // 3) gravar venda e obter recibo
                    Venda v = new Venda(cdCliente, total);
                    int recibo = v.persistir();

                    // 4) gravar ingresso associado à sessão e ao recibo
                    Ingresso i = new Ingresso(assento, cdSessao, recibo);
                    i.persistir();
                    
                    if (!lancheEscolhido.equals("Nenhum")) {
                        int cdLanche = 0;

                        switch (lancheEscolhido) {
                            case "Combo pipoca + refri": cdLanche = 1; break;
                            case "Pipoca média":         cdLanche = 2; break;
                            case "Refrigerante":         cdLanche = 3; break;
                            case "Doce":                 cdLanche = 4; break;
                        }

                        VendaLancheDAO.persistir(
                            recibo,
                            cdLanche,
                            quantidade,
                            Double.parseDouble(total.toString())
                        );
                    }


                    JOptionPane.showMessageDialog(null, "Ingresso vendido com sucesso!");

                    // limpar campos
                    txtNome.setText("");
                    txtEmail.setText("");
                    txtCpf.setValue(null);
                    txtAssento.setText("");

                } catch (Exception ex) {
                    ex.printStackTrace();
                    JOptionPane.showMessageDialog(null, "Erro: " + ex.getMessage());
                }
            }
        });
    }
}
