
const STORAGE_KEY = 'toulouse-treasure-hunt-data';

function loadData() {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved) {
        const data = JSON.parse(saved);
        
        // Restore checkboxes
        document.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
            if (data.checkboxes && data.checkboxes[checkbox.id]) {
                checkbox.checked = true;
            }
        });
        
        // Restore number inputs
        document.querySelectorAll('input[type="number"]').forEach(input => {
            if (data.numbers && data.numbers[input.id] !== undefined) {
                input.value = data.numbers[input.id];
            }
        });
    }
}

function saveData() {
    const data = {
        checkboxes: {},
        numbers: {}
    };
    
    document.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
        data.checkboxes[checkbox.id] = checkbox.checked;
    });
    
    document.querySelectorAll('input[type="number"]').forEach(input => {
        data.numbers[input.id] = parseInt(input.value) || 0;
    });
    
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
}

function calculateTrickScore(trick) {
    const trickId = trick.dataset.trickId;
    const completedCheckbox = trick.querySelector('.completed');
    const quantityInput = trick.querySelector('.quantity');
    const personalBestCheckbox = trick.querySelector('.personal-best');
    const holdingOnCheckbox = trick.querySelector('.holding-on');
    const isNegative = trick.dataset.negative === 'true';
    
    // Get base points from the trick
    const basePointsText = trick.querySelector('.base-points').textContent;
    const basePointsMatch = basePointsText.match(/-?\d+/);
    const basePoints = parseInt(basePointsMatch[0]);
    
    let score = 0;
    
    // Check if trick is completed
    if (completedCheckbox && completedCheckbox.checked) {
        score = basePoints;
    } else if (quantityInput) {
        const quantity = parseInt(quantityInput.value) || 0;
        score = basePoints * quantity;
    }
    
    // Apply multipliers
    if (personalBestCheckbox?.checked) {
        score *= 2;
    }
    if (holdingOnCheckbox?.checked) {
        score *= 0.5;
    }
    
    return Math.floor(score);
}

function updateCategoryProgress() {
    const categories = Array.from(document.querySelectorAll('section.category'))
        .map(section => section.dataset.category);
    console.log(`categories: ${categories}`);
    categories.forEach(category => {
        const tricks = document.querySelectorAll(`[data-category="${category}"]`);
        let total = 0;
        let completed = 0;
        
        tricks.forEach(trick => {
            // Skip negative tricks in the denominator
            if (trick.dataset.negative === 'true') {
                return;
            }
            
            total++;
            
            const completedCheckbox = trick.querySelector('.completed');
            const quantityInput = trick.querySelector('.quantity');
            
            if (completedCheckbox && completedCheckbox.checked) {
                completed++;
            } else if (quantityInput && (parseInt(quantityInput.value) || 0) > 0) {
                completed++;
            }
        });
        
        const progressElement = document.querySelector(`span.category-progress[data-category="${category}"]`);
        if (progressElement) {
            progressElement.textContent = `(${completed} / ${total})`;
        }
    });
}

function updateAllScores() {
    let totalScore = 0;
    
    document.querySelectorAll('.trick').forEach(trick => {
        const score = calculateTrickScore(trick);
        const scoreDisplay = trick.querySelector('.score-display');
        scoreDisplay.textContent = score + ' pts';
        totalScore += score;
        if (score == 0) {
            trick.classList.remove('completed');
        } else {
            trick.classList.add('completed');
        }
    });
    
    document.getElementById('total-points').textContent = totalScore;
    updateCategoryProgress();
    saveData();
}

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    loadData();
    updateAllScores();
    updateCategoryProgress();
    
    // Add event listeners
    document.querySelectorAll('input[type="checkbox"], input[type="number"]').forEach(input => {
        input.addEventListener('change', updateAllScores);
        input.addEventListener('input', updateAllScores);
    });
});