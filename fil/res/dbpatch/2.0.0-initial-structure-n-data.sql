
CREATE TABLE fil_magazine (
    magazine_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL DEFAULT '',
    image_url TEXT NOT NULL DEFAULT '',
    pdf_url TEXT NOT NULL DEFAULT '',
    pdf_size INTEGER NOT NULL DEFAULT 0,
    pdf_path TEXT DEFAULT '',
    is_read INTEGER NOT NULL DEFAULT 0,
    is_downloaded INTEGER NOT NULL DEFAULT 0,
    released_at TEXT NOT NULL DEFAULT '',
    created_at INTEGER NOT NULL DEFAULT 0,
    updated_at INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX fil_magazine_magazine_id_index ON fil_magazine (magazine_id);
