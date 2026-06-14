CREATE TABLE submissions (
  submission_id Utf8 NOT NULL,
  nickname Utf8 NOT NULL,
  mode Utf8 NOT NULL,
  created_at Utf8 NOT NULL,
  consent Bool NOT NULL,
  user_agent Utf8,
  PRIMARY KEY (submission_id)
);

CREATE TABLE answers (
  submission_id Utf8 NOT NULL,
  question_slug Utf8 NOT NULL,
  question_order Uint32,
  answer_text Utf8 NOT NULL,
  created_at Utf8 NOT NULL,
  hidden Bool NOT NULL,
  PRIMARY KEY (submission_id, question_slug)
);
