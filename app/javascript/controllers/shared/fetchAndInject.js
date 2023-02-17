export async function fetchAndInject(uri, resultsContainer) {
  return fetch(uri)
    .then(response => response.text())
    .then(text => {
      const parser = new DOMParser();
      const doc = parser.parseFromString(text, 'text/html');
      resultsContainer.innerHTML = doc.getElementById(resultsContainer.id).innerHTML;
    })
    .catch(function(err) {
      console.log('Failed to fetch page: ', err);
    });
}
