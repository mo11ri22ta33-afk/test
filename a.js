window.addEventListener("load", () => {
  const answer = confirm("あなたは人間ですか？");
  const resultEl = document.getElementById("result");
  if (answer) {
    resultEl.textContent = "あなたは人間です";
  } else {
    resultEl.textContent = "あなたは人間ではありません";
  }
});
