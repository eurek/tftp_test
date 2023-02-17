import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

    connect() {
        this.updateTags();

        document.querySelector("#content_category_id").onchange = this.updateTags;
    }

    updateTags() {
        const categoryId = document.querySelector("#content_category_id").value;
        let url = `/fr/admin/contents/tags_suggestions?category_id=${categoryId}`;

        fetch(url).then(response => response.json()).then(data => {
            const validTagIds = data.map(tag => tag.id.toString());
            const options = document.querySelectorAll("#content_tag_ids option");

            options.forEach(option => {
                const shouldDisplay = validTagIds.includes(option.value);
                option.disabled = !shouldDisplay;
            });
        });
    }
}
