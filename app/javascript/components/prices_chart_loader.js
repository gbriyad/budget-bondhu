document.addEventListener('DOMContentLoaded', function(event) {
    let accordions = document.querySelectorAll('.product-section .accordion-collapse')
    accordions.forEach(function(elem) {
        elem.addEventListener("show.bs.collapse", function(event) {
            let product_id = event.target.getAttribute('data-product-id');
            let source_url = event.target.getAttribute('data-chart-source-url');
            document.querySelector(`#product-chart-${product_id}`).textContent = 'Loading';

            let chart = Chartkick.charts[`product-chart-${product_id}`];
            chart.updateData(source_url);
        });
    });

    setTimeout(function () {
        document.querySelector('.product-section .accordion-button').click();
    }, 500);
});
