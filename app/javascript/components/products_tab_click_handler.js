document.addEventListener('DOMContentLoaded', function(event) {
    let profitable_product_btn = document.querySelector('#products_tab #profitable_product_btn');
    let non_profitable_product_btn = document.querySelector('#products_tab #non_profitable_product_btn');
    let profitable_products_section = document.querySelector('#profitable_products');
    let non_profitable_products_section = document.querySelector('#non_profitable_products');

    profitable_product_btn.addEventListener('click', function (event) {
        profitable_product_btn_click();
    })

    non_profitable_product_btn.addEventListener('click', function (event) {
        non_profitable_product_btn_click();
    })

    function profitable_product_btn_click() {
        profitable_product_btn.classList.add('active');
        non_profitable_product_btn.classList.remove('active')

        profitable_products_section.classList.remove('d-none');
        non_profitable_products_section.classList.add('d-none');
    }

    function non_profitable_product_btn_click() {
        non_profitable_product_btn.classList.add('active');
        profitable_product_btn.classList.remove('active')

        non_profitable_products_section.classList.remove('d-none');
        profitable_products_section.classList.add('d-none');
    }
});

