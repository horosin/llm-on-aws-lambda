PROMPT="Create five questions for a job interview for a senior python software engineer position."
# PROMPT="Generate a good name for a bakery."

curl $LAMBDA_URL -d "{ \"prompt\": \"$PROMPT\" }" \
    | jq -r '.choices[0].text, .usage'
