from transformers import GPT2LMHeadModel, GPT2Tokenizer
import torch

# モデルとトークナイザーのロード
model = GPT2LMHeadModel.from_pretrained("gpt2")
tokenizer = GPT2Tokenizer.from_pretrained("gpt2")

def generate_text(prompt: str):
    inputs = tokenizer.encode(prompt, return_tensors="pt")
    outputs = model.generate(inputs, max_length=100, num_return_sequences=1)
    return tokenizer.decode(outputs[0], skip_special_tokens=True)

if __name__ == "__main__":
    prompt = "Hello, how are you?"
    response = generate_text(prompt)
    print(response)
