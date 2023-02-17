export function getTranslation(translationKey) {
  const locale = location.pathname.split("/")[1];
  const queryParams = `?locale=${locale}&translation_key=${translationKey}`;
  const fetchUri = location.origin + "/api/translations" + queryParams;

  return fetch(fetchUri).then(response => response.json());
}
