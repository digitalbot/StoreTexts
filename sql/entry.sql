CREATE TABLE IF NOT EXISTS entry (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    object_id VARCHAR(255) NOT NULL UNIQUE,
    nickname VARCHAR(255) NOT NULL,
    body TEXT,
    extra VARCHAR(255),
    created_at DATETIME NOT NULL,
    INDEX index_created_at(created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
