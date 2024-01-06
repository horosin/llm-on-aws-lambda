PROMPT="Create five questions for a job interview for a senior python software engineer position."

curl $LAMBDA_URL -d "{ \"prompt\": \"$PROMPT\" }" \
    | jq -r '.choices[0].text, .usage'
