package apresentacao;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JTextField;

public class VisaoPessoa extends JFrame {
	//Propriedade da classe
	private static final long serialVersionUID = 1L;
	
	private JLabel lblNome = new JLabel("Nome");
	private JTextField txtNome = new JTextField();
	
	private JLabel lblEmail = new JLabel("Email");
	private JTextField txtEmail = new JTextField();
	
	private JLabel lblTelefone = new JLabel("Telefone");
	private JTextField txtTelefone = new JTextField();
	
	private JButton btnGravar = new JButton("Gravar");
	
	//Métodos principal de execução da classe
	public static void main(String[] args) {
		new VisaoPessoa().setVisible(true);
	}
	//Método construtor da classe
	public VisaoPessoa() {
		//Configuração da janela
		setTitle("Cadastro de Pessoa");
		setSize(400, 230);
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		setLocationRelativeTo(null);
		setLayout(null);
		
		//Configuração do nome
		lblNome.setBounds(10, 10, 200, 20);
		add(lblNome);
		txtNome.setBounds(10, 30, 365, 20);
		add(txtNome);
		
		//Configuração do endereço
		lblEmail.setBounds(10, 60, 200, 20);
		add(lblEmail);
		txtEmail.setBounds(10, 80, 365, 20);
		add(txtEmail);
		
		//Configuração do telefone
		lblTelefone.setBounds(10, 110, 200, 20);
		add(lblTelefone);
		txtTelefone.setBounds(10, 130, 100, 20);
		add(txtTelefone);
		
		//Configuração do botão
		btnGravar.setBounds(150, 160, 100, 20);
		add(btnGravar);
		btnGravar.addActionListener(new ControladorGravar(txtNome, txtEmail, txtTelefone));
	}
}
