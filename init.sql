CREATE TABLE IF NOT EXISTS etudiants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL
);

INSERT INTO etudiants (nom, prenom) VALUES 
('Ben Abdeljalil', 'Bahija'),
('Dupont', 'Jean'),
('Martin', 'Sophie');
