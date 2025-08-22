
CREATE DATABASE IF NOT EXISTS `controlefinancas`;
USE `controlefinancas`;


CREATE TABLE IF NOT EXISTS `pessoas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `telefone` varchar(15) DEFAULT NULL,
  `cpf` varchar(11) NOT NULL,
  `endereco` varchar(255) DEFAULT NULL,
  `CreatedAt` timestamp NULL DEFAULT current_timestamp(),
  `UpdatedAt` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `cpf` (`cpf`)
);

CREATE TABLE `movimentacao` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `idPessoa` INT(11) NULL DEFAULT NULL,
    `Credito` DECIMAL(15,2) NULL DEFAULT NULL,
    `Debito` DECIMAL(15,2) NULL DEFAULT NULL,
    `DataOperacao` TIMESTAMP NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    `OBS` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
    `CreatedAt` TIMESTAMP NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `id` (`id`) USING BTREE,
    INDEX `FK_ID_PESSOA` (`idPessoa`) USING BTREE,
    CONSTRAINT `FK_ID_PESSOA` FOREIGN KEY (`idPessoa`) REFERENCES `pessoas` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=4

""
ALTER TABLE movimentacao MODIFY COLUMN DataOperacao DATETIME;
""
;

 CREATE TABLE IF NOT EXISTS `pessoasExcluidas` (
  `id` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `telefone` varchar(15) DEFAULT NULL,
  `cpf` varchar(11) NOT NULL,
  `endereco` varchar(255) DEFAULT NULL,
  `excluidoEm` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `cpf` (`cpf`)
);