document.addEventListener('DOMContentLoaded', function(event) {

    // handle dropdown click
    let dropdowns = document.querySelectorAll('#products-filter-form .dropdown');
    document.addEventListener('click', function (event) {
        if(document.body === event.target) {
            dropdowns.forEach(function (dropdown) {
                dropdown.classList.remove('active');
            });
        }
    });

    // handle option selection for dropdown
    let filter_form = document.querySelector('#products-filter-form');
    let inputFields = document.querySelectorAll('#products-filter-form input:not([hidden])');
    let option_sections = document.querySelectorAll('.dropdown .options');

    option_sections.forEach(function(elem) {
        elem.addEventListener("click", function(event) {
            if(elem.previousSibling.value === event.target.textContent) {
                return;
            }
            elem.previousSibling.value = event.target.textContent;
            elem.previousSibling.previousSibling.value = event.target.getAttribute('value');

            inputFields.forEach(function (inputField) {
                inputField.disabled = true;
            })
            filter_form.submit();
        });
    });
});

