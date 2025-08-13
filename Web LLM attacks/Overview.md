Example of LLM attacks:
- Retrieve data that the LLM has access to. Common sources of such data include the LLM's prompt, training set, and APIs provided to the model.
- Trigger harmful actions via APIs. For example, the attacker could use an LLM to perform a SQL injection attack on an API it has access to.
- Trigger attacks on other users and systems that query the LLM.

![](Pasted%20image%2020250813111038.png)

# What is a large language model?

Large Language Models (LLMs) are AI algorithms that can process user inputs and create plausible responses by predicting sequences of words. 

LLMs can have a wide range of use cases in modern websites:
- Customer service, such as a virtual assistant.
- Translation.
- SEO improvement.
- Analysis of user-generated content, for example to track the tone of on-page comments.

# LLM attack and prompt injection

Prompt injection can result in the AI taking actions that fall outside of its intended purpose, such as making incorrect calls to sensitive APIs or returning content that does not correspond to its guidelines.

# Detecting LLM vulnerabilities

Our recommended methodology for detecting LLM vulnerabilities is:

- Identify the **LLM's inputs**, including both **direct (such as a prompt) and indirect (such as training data) inputs.**
- Work out **what data and APIs** the LLM has access to.
- **Probe this new attack** surface for vulnerabilities.