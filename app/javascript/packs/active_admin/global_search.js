const globalSearch = () => {
    let nav = document.querySelector('ul#utility_nav');
    const form = `
      <li class='menu_item'>
        <form action='/fr/admin/search' accept-charset='UTF-8' class='global-search'>
          <input name='utf8' type='hidden' value='✓'>
          <input type='text' name='query' id='query' placeholder='Global search' class='input-text'>
          <input type='submit' name='commit' value='Find' data-disable-with='Find' class='submit-button'>
        </form>
      </li>
    `
    nav.insertAdjacentHTML("afterbegin", form);
}

export { globalSearch };
