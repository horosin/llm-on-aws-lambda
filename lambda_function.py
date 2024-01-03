import base64
import json
from llama_cpp import Llama


llm = Llama(
    model_path="./model/phi-2.Q4_K_M.gguf",
    n_ctx=2048,
    n_threads=6,  # maximum in AWS Lambda
)


def handler(event, context):
    print("Event is:", event)
    print("Context is:", context)

    try:
        if event.get('isBase64Encoded', False):
            body = base64.b64decode(event['body']).decode('utf-8')
        else:
            body = event['body']

        body_json = json.loads(body)
        prompt = body_json["prompt"]
    except (KeyError, json.JSONDecodeError) as e:
        return {"statusCode": 400, "body": f"Error processing request: {str(e)}"}

    output = llm(
        f"Instruct: {prompt}\nOutput:",
        max_tokens=512, 
        echo=True,
    )

    return {
        "statusCode": 200,
        "body": json.dumps(output)
    }
